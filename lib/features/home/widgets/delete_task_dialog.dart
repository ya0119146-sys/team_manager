import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_manager/features/home/cubit/delete_task_cubit/delete_task_cubit.dart';
import 'package:team_manager/features/home/cubit/delete_task_cubit/delete_task_state.dart';
import 'package:team_manager/features/home/cubit/get_project_tasks_cubit/get_project_tasks_cubit.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:easy_localization/easy_localization.dart';

Future<void> showDeleteTaskDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
  required String projectId,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return BlocConsumer<DeleteTaskCubit, DeleteTaskState>(
        listener: (context, state) {
          if (state is DeleteTaskSuccess) {
            BlocProvider.of<GetProjectTasksCubit>(
              context,
            ).getProjectTasks(projectId: projectId);

            customScafoldMessenger(
              context,
              'Task deleted successfully'.tr(),
              color: Colors.green,
            );
            GoRouter.of(context).pop();
          } else if (state is DeleteTaskError) {
            GoRouter.of(context).pop();
            customScafoldMessenger(
              context,
              'Failed to delete task'.tr(),
              color: Colors.red,
            );
          }
        },
        builder: (context, state) {
          final theme = Theme.of(context);
          return AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Delete Task'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to delete this task?'.tr(),
              style: theme.textTheme.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'.tr(), style: theme.textTheme.bodyMedium),
              ),
              GlassButton(
                width: 100,
                height: 40,
                gradient: LinearGradient(
                  colors: [theme.colorScheme.error, theme.colorScheme.error],
                ),
                label: 'Delete'.tr(),
                onPressed: () {
                  onConfirm();
                },
              ),
            ],
          );
        },
      );
    },
  );
}
