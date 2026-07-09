import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:team_manager/features/home/cubit/delete_project_cubit/delete_project_cubit.dart';
import 'package:team_manager/features/home/cubit/delete_project_cubit/delete_project_state.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_cubit.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:easy_localization/easy_localization.dart';

class DeleteProjectDialog extends StatelessWidget {
  final String projectID;
  final bool projectDetails;
  final Function()? onPressed;
  const DeleteProjectDialog({
    super.key,
    required this.projectID,
    this.projectDetails = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final deleteProjectCubit = DeleteProjectCubit.get(context);
    final projectCubit = ProjectCubit.get(context);

    return BlocConsumer<DeleteProjectCubit, DeleteProjectState>(
      listener: (context, state) {
        if (state is DeleteProjectSuccess) {
          projectCubit.getProjects();
          if (projectDetails) {
            onPressed?.call();
          }
          customScafoldMessenger(
            context,
            'Project deleted successfully'.tr(),
            color: Colors.green,
          );
          Navigator.pop(context);
        } else if (state is DeleteProjectError) {
          customScafoldMessenger(context, state.message, color: Colors.red);
        }
      },
      builder: (context, state) {
        final theme = Theme.of(context);
        return ModalProgressHUD(
          inAsyncCall: state is DeleteProjectloading,
          progressIndicator: const CircularProgressIndicator(),
          child: AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Delete project'.tr(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to delete this project?'.tr(),
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
                  deleteProjectCubit.deleteProject(projectID);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
