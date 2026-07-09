import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/core/helpers/secure_storage_helper.dart';
import 'package:team_manager/core/utils/app_router.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_bloc.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_event.dart';

class ProfileMenuContent extends StatelessWidget {
  const ProfileMenuContent({super.key, required this.onSettingsPressed});

  final VoidCallback onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final role = CacheHelper.getData(key: 'role')?.toString() ?? 'member';
    final email = CacheHelper.getData(key: 'email')?.toString() ?? '';
    final username = CacheHelper.getData(key: 'username')?.toString() ?? 'User';

    return GlassPanel(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Section with Avatar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                  child: Text(
                    username.isNotEmpty ? username[0].toUpperCase() : 'U',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (email.isNotEmpty)
                        Text(
                          email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Role Badge Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              margin: const EdgeInsets.only(top: 4, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    role.toLowerCase() == 'admin'
                        ? Icons.admin_panel_settings
                        : Icons.person_outline,
                    size: 12,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 0.5,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Divider(
              height: 1,
              thickness: 1,
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 4),

          // Menu Items
          _buildMenuItem(
            context: context,
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              onSettingsPressed();
            },
          ),
          
          _buildMenuItem(
            context: context,
            icon: Icons.logout_rounded,
            title: 'Logout',
            isDestructive: true,
            onTap: () async {
              Navigator.pop(context); // Close the popup menu

              if (context.mounted) {
                context.read<ChatBloc>().add(const DisconnectSocketEvent());
              }

              await SecureStorageHelper.deleteToken();
              await CacheHelper.setBool(key: 'auth_active', value: false);
              await CacheHelper.removeData(key: 'role');
              await CacheHelper.removeData(key: 'email');
              await CacheHelper.removeData(key: 'username');

              if (context.mounted) {
                GoRouter.of(context).pushReplacement(AppRouter.kLoginScreen);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: color.withValues(alpha: 0.05),
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color.withValues(alpha: 0.8)),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
