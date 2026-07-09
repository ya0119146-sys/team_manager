import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/home/cubit/get_user_profile_cubit/get_user_profile_cubit.dart';
import 'package:team_manager/features/home/cubit/get_user_profile_cubit/get_user_profile_state.dart';
import 'package:team_manager/features/chat/widgets/private_chat_screen.dart';
import 'package:team_manager/core/widgets/empty_state_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class PrivateScreen extends StatefulWidget {
  const PrivateScreen({super.key});

  @override
  State<PrivateScreen> createState() => _PrivateScreenState();
}

class _PrivateScreenState extends State<PrivateScreen> {
  List<String> teamMates = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<GetUserProfileCubit>(context).getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Chats'.tr()),
        backgroundColor: Colors.transparent,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: BlocBuilder<GetUserProfileCubit, GetUserProfileState>(
        builder: (context, state) {
          if (state is GetUserProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GetUserProfileError) {
            return Center(child: Text(state.error));
          }
          if (state is GetUserProfileSuccess) {
            teamMates = state.profileModel.teamMates;

            if (teamMates.isEmpty) {
              return Center(
                child: EmptyStateWidget(
                  icon: Icons.chat_bubble_outline,
                  title: 'No teammates available'.tr(),
                  subtitle: 'Invite teammates to start chatting'.tr(),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: teamMates.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, indent: 72, endIndent: 16),
              itemBuilder: (context, index) {
                final teammate = teamMates[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: _getAvatarColor(index),
                    child: Text(
                      teammate.length >= 2
                          ? teammate.substring(0, 2).toUpperCase()
                          : teammate.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  title: Text(
                    teammate,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Tap to start chatting'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(DateTime.now()),
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '1',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PrivateChatScreen(receiverUsername: teammate),
                      ),
                    );
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Color _getAvatarColor(int index) {
    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.purple.shade600,
      Colors.orange.shade600,
      Colors.red.shade600,
      Colors.teal.shade600,
      Colors.indigo.shade600,
      Colors.pink.shade600,
    ];
    return colors[index % colors.length];
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Now'.tr();
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}${'m'.tr()}';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}${'h'.tr()}';
    } else if (difference.inDays == 1) {
      return 'Yesterday'.tr();
    } else if (difference.inDays < 7) {
      return '${difference.inDays}${'d'.tr()}';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
