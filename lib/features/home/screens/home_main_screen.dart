import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/core/helpers/secure_storage_helper.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_cubit.dart';
import 'package:team_manager/features/home/cubit/get_user_profile_cubit/get_user_profile_cubit.dart';
import 'package:team_manager/features/home/screens/home_dashboard_screen.dart';
import 'package:team_manager/features/home/screens/home_project_screen.dart';
import 'package:team_manager/features/home/screens/home_task_screen.dart';
import 'package:team_manager/features/chat/screens/private_screen.dart';
import 'package:team_manager/features/notification/cubits/get_unread_count_cubit/get_unread_count_cubit.dart';
import 'package:team_manager/features/notification/cubits/get_unread_count_cubit/get_unread_count_state.dart';
import 'package:team_manager/features/notification/cubits/notification_socket_cubit/notification_socket_cubit.dart';
import 'package:team_manager/features/notification/screens/notification_screen.dart';
import 'package:team_manager/features/home/widgets/profile_menu_content.dart';
import 'package:team_manager/features/settings/cubits/theme_cubit/theme_cubit.dart';
import 'package:team_manager/features/settings/screens/profile_settings_screen.dart';
import 'package:team_manager/features/home/widgets/create_new_project_dialog.dart';
import 'package:team_manager/features/home/widgets/create_new_task_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeMainScreen extends StatefulWidget {
  const HomeMainScreen({super.key, required this.isAdmin});
  final bool isAdmin;

  @override
  State<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String token = '';
  String username = 'U';

  late int currentIndex;

  int get dashboardIndex => 0;
  int get projectsIndex => 1;
  int get tasksIndex => 2;
  int get chatIndex => 3;
  int get settingsIndex => 4;
  int get notificationsIndex => 5;

  List<Widget> get screens => [
    HomeDashboardScreen(onNavigate: changeScreen, isAdmin: widget.isAdmin),
    HomeProjectScreen(isAdmin: widget.isAdmin),
    HomeTaskScreen(isAdmin: widget.isAdmin),
    const PrivateScreen(),
    const ProfileSettingsScreen(),
    const NotificationsScreen(),
  ];

  void changeScreen(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    currentIndex = dashboardIndex;
    _initData();
  }

  Future<void> _initData() async {
    final fetchedToken = await SecureStorageHelper.getToken();
    final cachedUsername = CacheHelper.getData(key: 'username')?.toString();

    if (mounted) {
      setState(() {
        token = fetchedToken ?? '';
        username = (cachedUsername != null && cachedUsername.isNotEmpty)
            ? cachedUsername
            : 'AM';
      });

      if (token.isNotEmpty) {
        BlocProvider.of<NotificationSocketCubit>(
          context,
        ).getNotifications(token);
        BlocProvider.of<GetUnreadCountCubit>(context).getUnreadCount();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,

      // ================= PREMIUM DRAWER =================
      drawer: Drawer(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Premium Drawer Header Block
              Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'TM',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Team Manager',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              widget.isAdmin
                                  ? 'ADMIN PORTAL'.tr()
                                  : 'MEMBER PORTAL'.tr(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: theme.hintColor.withValues(alpha: 0.7),
                      ),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Action Buttons (Admins only)
              if (widget.isAdmin)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (_) => const CreateProjectDialog(),
                            );
                          },
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: Text(
                            'New Project'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (_) => const CreateNewTaskDialog(),
                            );
                          },
                          icon: const Icon(Icons.add_task_rounded, size: 18),
                          label: Text(
                            'New Task'.tr(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            side: BorderSide(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.5,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

              // Navigation section header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Text(
                  'MAIN MENU'.tr(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: theme.hintColor.withValues(alpha: 0.6),
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              // Nav List Tiles
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildDrawerTile(
                      theme: theme,
                      icon: Icons.dashboard_outlined,
                      selectedIcon: Icons.dashboard_rounded,
                      label: 'Dashboard'.tr(),
                      index: dashboardIndex,
                    ),
                    _buildDrawerTile(
                      theme: theme,
                      icon: Icons.folder_open_outlined,
                      selectedIcon: Icons.folder_rounded,
                      label: 'Projects'.tr(),
                      index: projectsIndex,
                    ),
                    _buildDrawerTile(
                      theme: theme,
                      icon: Icons.assignment_outlined,
                      selectedIcon: Icons.assignment_rounded,
                      label: 'All Tasks'.tr(),
                      index: tasksIndex,
                    ),
                    _buildDrawerTile(
                      theme: theme,
                      icon: Icons.chat_bubble_outline_rounded,
                      selectedIcon: Icons.chat_bubble_rounded,
                      label: 'Chat'.tr(),
                      index: chatIndex,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, indent: 16, endIndent: 16),
              const SizedBox(height: 8),

              // Bottom Settings
              _buildDrawerTile(
                theme: theme,
                icon: Icons.settings_outlined,
                selectedIcon: Icons.settings_rounded,
                label: 'Settings'.tr(),
                index: settingsIndex,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      // ================= BODY =================
      body: SafeArea(
        child: Column(
          children: [
            /// ================= PREMIUM TOP BAR =================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha:
                          context.watch<ThemeCubit>().state.themeMode ==
                              ThemeMode.dark
                          ? 0.3
                          : 0.05,
                    ),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Menu Button
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.05),
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.menu_rounded,
                        size: 26,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () => scaffoldKey.currentState?.openDrawer(),
                      padding: const EdgeInsets.all(12),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Logo Badge
                  GestureDetector(
                    onTap: () => changeScreen(dashboardIndex),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'TM',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Theme Toggle
                  IconButton(
                    icon: Icon(
                      context.watch<ThemeCubit>().state.themeMode ==
                              ThemeMode.dark
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      size: 24,
                    ),
                    onPressed: () =>
                        BlocProvider.of<ThemeCubit>(context).toggleTheme(),
                  ),
                  const SizedBox(width: 4),

                  // Notifications
                  BlocBuilder<GetUnreadCountCubit, GetUnreadCountState>(
                    builder: (context, state) {
                      int unreadCount = 0;
                      if (state is GetUnreadCountSuccess) {
                        unreadCount = state.unreadCount;
                      }

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              size: 26,
                            ),
                            onPressed: () => changeScreen(notificationsIndex),
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 22,
                                  minHeight: 22,
                                ),
                                child: Center(
                                  child: Text(
                                    unreadCount > 99
                                        ? '99+'
                                        : unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 8),

                  // Avatar Menu
                  PopupMenuButton<int>(
                    offset: const Offset(0, 48),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                        child: Text(
                          username.isNotEmpty
                              ? username
                                    .substring(0, username.length >= 2 ? 2 : 1)
                                    .toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem<int>(
                        value: 0,
                        enabled: false,
                        child: ProfileMenuContent(
                          onSettingsPressed: () => changeScreen(settingsIndex),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// ================= SCREEN CONTENT =================
            Expanded(child: screens[currentIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required ThemeData theme,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = currentIndex == index;
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          if (index == projectsIndex || index == tasksIndex) {
            BlocProvider.of<ProjectCubit>(context).getProjects();
          }
          changeScreen(index);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: primary.withValues(alpha: 0.1),
        highlightColor: primary.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? primary.withValues(alpha: isDark ? 0.15 : 0.08)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? primary.withValues(alpha: 0.2)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? primary
                    : theme.hintColor.withValues(alpha: 0.7),
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? primary
                        : (isDark ? Colors.white70 : Colors.black87),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
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
}
