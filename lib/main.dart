import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/core/theme/app_theme.dart';
import 'package:team_manager/core/utils/app_router.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/core/helpers/dio_helper.dart';
import 'package:team_manager/core/helpers/secure_storage_helper.dart';
import 'package:team_manager/features/home/cubit/add_project_member_cubit/add_project_member_cubit.dart';
import 'package:team_manager/features/home/cubit/create_new_task_cubit/create_new_task_cubit.dart';
import 'package:team_manager/features/home/cubit/delete_member_cubit/delete_member_cubit.dart';
import 'package:team_manager/features/home/cubit/delete_task_cubit/delete_task_cubit.dart';
import 'package:team_manager/features/home/cubit/delete_user_profile_cubit/delete_user_profile_cubit.dart';
import 'package:team_manager/features/home/cubit/get_admin_dashboard_cubit/get_admin_dashboard_cubit.dart';
import 'package:team_manager/features/home/cubit/get_project_tasks_cubit/get_project_tasks_cubit.dart';
import 'package:team_manager/features/home/cubit/get_user_profile_cubit/get_user_profile_cubit.dart';
import 'package:team_manager/features/home/cubit/get_user_task_cubit/get_user_task_cubit.dart';
import 'package:team_manager/features/home/cubit/update_task_cubit/update_task_cubit.dart';
import 'package:team_manager/features/home/cubit/update_task_status_cubit/update_task_status_cubit.dart';
import 'package:team_manager/features/home/cubit/update_user_profile_cubit/update_user_profile_cubit.dart';
import 'package:team_manager/features/auth/cubit/forget_password_cubit/forget_password_cubit.dart';
import 'package:team_manager/features/home/cubit/create_project_cubit/create_project_cubit.dart';
import 'package:team_manager/features/home/cubit/delete_project_cubit/delete_project_cubit.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_cubit.dart';
import 'package:team_manager/features/home/cubit/update_project_cubit/update_project_cubit.dart';
import 'package:team_manager/features/auth/cubit/auth_cubit/login_cubit.dart';
import 'package:team_manager/features/auth/cubit/register_cubit/register_cubit.dart';
import 'package:team_manager/features/auth/cubit/verify_code_register_cubit/verify_code_cubit.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_bloc.dart';
import 'package:team_manager/features/chat/cubit/chat_cubit/chat_event.dart';
import 'package:team_manager/features/notification/cubits/edit_viewed_notification_cubit/edit_viewed_notification_cubit.dart';
import 'package:team_manager/features/notification/cubits/get_unread_count_cubit/get_unread_count_cubit.dart';
import 'package:team_manager/features/notification/cubits/get_your_notification_cubit/get_your_notification_cubit.dart';
import 'package:team_manager/features/notification/cubits/mark_all_done_cubit/mark_all_done_cubit.dart';
import 'package:team_manager/features/notification/cubits/notification_socket_cubit/notification_socket_cubit.dart';
import 'package:team_manager/features/settings/cubits/theme_cubit/theme_cubit.dart';
import 'package:team_manager/features/settings/cubits/theme_cubit/theme_state.dart';
import 'package:team_manager/features/settings/cubits/change_passwordcubit/change_password_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await DioHelper.init();
  await CacheHelper.init();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      useFallbackTranslations: true,
      child: const TeamManager(),
    ),
  );
}

class TeamManager extends StatelessWidget {
  const TeamManager({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LoginCubit()),
        BlocProvider(create: (context) => RegisterCubit()),
        BlocProvider(create: (context) => ProjectCubit()),
        BlocProvider(create: (context) => VerifyCodeRegisterCubit()),
        BlocProvider(create: (context) => AddProjectMemberCubit()),
        BlocProvider(create: (context) => DeleteProjectCubit()),
        BlocProvider(create: (context) => UpdateProjectCubit()),
        BlocProvider(create: (context) => CreateProjectCubit()),
        BlocProvider(create: (context) => GetUserTaskCubit()),
        BlocProvider(create: (context) => CreateNewTaskCubit()),
        BlocProvider(create: (context) => DeleteTaskCubit()),
        BlocProvider(create: (context) => UpdateTaskCubit()),
        BlocProvider(create: (context) => UpdateTaskStatusCubit()),
        BlocProvider(create: (context) => ForgetPasswordCubit()),
        BlocProvider(create: (context) => GetProjectTasksCubit()),
        BlocProvider(create: (context) => GetAdminDashboardCubit()),
        BlocProvider(create: (context) => DeleteUserProfileCubit()),
        BlocProvider(create: (context) => UpdateUserProfileCubit()),
        BlocProvider(
          create: (context) => GetUserProfileCubit()..getUserProfile(),
        ),
        BlocProvider(create: (context) => DeleteMemberCubit()),

        // ── Chat (single unified BLoC) ───────────────────────────────────
        // We initialize the socket lazily; the bloc connects once we have
        // the token from SecureStorage (read in _ChatInitializer).
        BlocProvider(create: (context) => ChatBloc()),

        // ── Notifications ────────────────────────────────────────────────
        BlocProvider(create: (context) => NotificationSocketCubit()),
        BlocProvider(create: (context) => GetYourNotificationCubit()),
        BlocProvider(create: (context) => EditViewedNotificationCubit()),
        BlocProvider(create: (context) => MarkAllDoneCubit()),
        BlocProvider(create: (context) => GetUnreadCountCubit()),

        BlocProvider(create: (context) => ThemeCubit()),
        BlocProvider(create: (context) => ChangePasswordCubit()),
      ],
      child: _ChatInitializer(
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'TeamManager',
              themeMode: themeState.themeMode,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}

/// Reads token + username from SecureStorage (async) and fires the connect
/// event on the ChatBloc. Placed above the router so the socket is ready
/// before any chat screen is opened.
class _ChatInitializer extends StatefulWidget {
  final Widget child;
  const _ChatInitializer({required this.child});

  @override
  State<_ChatInitializer> createState() => _ChatInitializerState();
}

class _ChatInitializerState extends State<_ChatInitializer> {
  @override
  void initState() {
    super.initState();
    _connectChat();
  }

  Future<void> _connectChat() async {
    final token = await SecureStorageHelper.getToken();
    final username = await SecureStorageHelper.getUsername();
    if (token != null && token.isNotEmpty && mounted) {
      context.read<ChatBloc>().add(
        ConnectSocketEvent(token: token, currentUsername: username ?? ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
