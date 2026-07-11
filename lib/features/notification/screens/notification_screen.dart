import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:team_manager/features/notification/cubits/edit_viewed_notification_cubit/edit_viewed_notification_cubit.dart';
import 'package:team_manager/features/notification/cubits/get_unread_count_cubit/get_unread_count_cubit.dart';
import 'package:team_manager/features/notification/cubits/get_your_notification_cubit/get_your_notification_cubit.dart';
import 'package:team_manager/features/notification/cubits/get_your_notification_cubit/get_your_notification_state.dart';
import 'package:team_manager/features/notification/cubits/mark_all_done_cubit/mark_all_done_cubit.dart';
import 'package:team_manager/features/notification/cubits/notification_socket_cubit/notification_socket_cubit.dart';
import 'package:team_manager/features/notification/cubits/notification_socket_cubit/notification_socket_state.dart';
import 'package:team_manager/features/notification/models/notification_model.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';
import 'package:team_manager/core/widgets/empty_state_widget.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // REST cubit to load history
        BlocProvider(
          create: (_) => GetYourNotificationCubit()..getNotifications(),
        ),
        BlocProvider(create: (_) => MarkAllDoneCubit()),
        BlocProvider(create: (_) => EditViewedNotificationCubit()),
      ],
      child: const _NotificationsBody(),
    );
  }
}

class _NotificationsBody extends StatefulWidget {
  const _NotificationsBody();

  @override
  State<_NotificationsBody> createState() => _NotificationsBodyState();
}

class _NotificationsBodyState extends State<_NotificationsBody> {
  bool _historySeedDone = false;

  void _onHistoryLoaded(BuildContext context, List<NotificationModel> history) {
    if (_historySeedDone) return;
    _historySeedDone = true;

    final token = CacheHelper.getData(key: 'token')?.toString() ?? '';
    // Seed REST history into the persistent socket cubit
    context.read<NotificationSocketCubit>().getNotifications(
      token,
      initialMessages: history,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notifications'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      body: BlocListener<GetYourNotificationCubit, GetYourNotificationState>(
        listener: (context, state) {
          if (state is GetYourNotificationSuccess) {
            _onHistoryLoaded(context, state.notifications);
          }
          if (state is GetYourNotificationError) {
            if (!_historySeedDone) {
              _historySeedDone = true;
              final token = CacheHelper.getData(key: 'token')?.toString() ?? '';
              context.read<NotificationSocketCubit>().getNotifications(token);
            }
            customScafoldMessenger(
              context,
              state.message,
              color: Colors.orange,
            );
          }
        },
        child: BlocBuilder<NotificationSocketCubit, NotificationSocketState>(
          builder: (context, socketState) {
            return Column(
              children: [
                _buildStatusBanner(socketState),
                Expanded(child: _buildNotificationList(socketState)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBanner(NotificationSocketState state) {
    if (state is NotificationLoading && !_historySeedDone) {
      return const LinearProgressIndicator();
    }
    return const SizedBox.shrink();
  }

  Widget _buildNotificationList(NotificationSocketState state) {
    // Show spinner if both REST and socket initialization are loading
    if (!_historySeedDone && state is NotificationLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final list = (state is NotificationLoaded)
        ? state.notifications
        : <NotificationModel>[];

    if (list.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.notifications_off_outlined,
          title: 'All caught up!'.tr(),
          subtitle: 'No new notifications to display.'.tr(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${list.where((n) => !n.isRead).length} ${'unread'.tr()}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).hintColor,
                ),
              ),
              if (list.any((n) => !n.isRead))
                SizedBox(
                  width: 140,
                  height: 36,
                  child: GlassButton(
                    onPressed: () {
                      context.read<MarkAllDoneCubit>().markAllDone();
                      // Optimistic local UI update
                      context
                          .read<NotificationSocketCubit>()
                          .markAllAsReadLocally();
                      // Refresh top-bar unread count badge
                      context.read<GetUnreadCountCubit>().getUnreadCount();
                    },
                    icon: Icons.done_all_rounded,
                    label: 'Mark all read'.tr(),
                    isOutlined: true,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = list[index];
                return _NotificationItem(item: item);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatefulWidget {
  final NotificationModel item;

  const _NotificationItem({required this.item});

  @override
  State<_NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<_NotificationItem>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.0,
      upperBound: 0.03,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.item.isRead || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Trigger REST patch call and wait for it
      await context.read<EditViewedNotificationCubit>().editViewedNotification(
        widget.item.id,
      );

      // Trigger local Optimistic UI update instantly
      if (mounted) {
        context.read<NotificationSocketCubit>().markAsReadLocally(
          widget.item.id,
        );
        // Trigger badge count refresh
        context.read<GetUnreadCountCubit>().getUnreadCount();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color iconColor = _getIconColor(widget.item.type);
    final IconData iconData = _getIcon(widget.item.type);

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        _animationController.reverse();
        _handleTap();
      },
      onTapCancel: () => _animationController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: widget.item.isRead
                ? theme.colorScheme.surface
                : (isDark
                      ? theme.colorScheme.primary.withValues(alpha: 0.05)
                      : theme.colorScheme.primary.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.item.isRead
                  ? theme.dividerColor.withValues(alpha: 0.1)
                  : theme.colorScheme.primary.withValues(alpha: 0.2),
              width: widget.item.isRead ? 1 : 1.5,
            ),
            boxShadow: widget.item.isRead
                ? []
                : [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.item.isRead
                      ? theme.disabledColor.withValues(alpha: 0.1)
                      : iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: widget.item.isRead
                      ? theme.hintColor.withValues(alpha: 0.6)
                      : iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.item.type,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: widget.item.isRead
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              color: widget.item.isRead
                                  ? theme.hintColor
                                  : theme.textTheme.titleMedium?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!widget.item.isRead) ...[
                          const SizedBox(width: 8),
                          if (_isLoading)
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          else
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.4,
                                    ),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.item.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: widget.item.isRead
                            ? theme.textTheme.bodyMedium?.color?.withValues(
                                alpha: 0.6,
                              )
                            : theme.textTheme.bodyMedium?.color,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: theme.hintColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.item.formattedDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('task')) return Icons.task_alt_rounded;
    if (lowerType.contains('project')) return Icons.folder_special_rounded;
    return Icons.notifications_active_rounded;
  }

  Color _getIconColor(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('task')) return Colors.orange;
    if (lowerType.contains('project')) return Colors.blue;
    return Colors.purple;
  }
}
