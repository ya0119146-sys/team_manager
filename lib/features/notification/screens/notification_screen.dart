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
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                      context.read<NotificationSocketCubit>().markAllAsReadLocally();
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

class _NotificationItem extends StatelessWidget {
  final NotificationModel item;

  const _NotificationItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (!item.isRead) {
          // Trigger REST patch call
          context.read<EditViewedNotificationCubit>().editViewedNotification(item.id);
          // Trigger local Optimistic UI update instantly
          context.read<NotificationSocketCubit>().markAsReadLocally(item.id);
          // Trigger badge count refresh
          context.read<GetUnreadCountCubit>().getUnreadCount();
        }
      },
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: item.isRead
            ? null
            : Border.all(
                color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.2),
                width: 1.5,
              ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getIconColor(item.type).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(item.type),
                color: _getIconColor(item.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.type,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: item.isRead ? FontWeight.w500 : FontWeight.bold,
                      color: item.isRead ? theme.hintColor : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: item.isRead
                          ? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6)
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('task')) return Icons.assignment_outlined;
    if (lowerType.contains('project')) return Icons.folder_outlined;
    return Icons.notifications_none_rounded;
  }

  Color _getIconColor(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('task')) return Colors.orange;
    if (lowerType.contains('project')) return Colors.blue;
    return Colors.purple;
  }
}
