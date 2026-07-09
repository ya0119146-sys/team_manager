import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:team_manager/features/home/cubit/add_project_member_cubit/add_project_member_cubit.dart';
import 'package:team_manager/features/home/cubit/add_project_member_cubit/add_project_member_state.dart';
import 'package:team_manager/features/home/cubit/delete_member_cubit/delete_member_cubit.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';
import 'package:team_manager/core/widgets/glass_input_field.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:team_manager/features/auth/widgets/input_label.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_cubit.dart';

class MembersTab extends StatefulWidget {
  const MembersTab({
    super.key,
    required this.totalMembers,
    required this.id,
    required this.usernameMembers,
    required this.emails,
    required this.isAdmin,
  });

  final String totalMembers;
  final String id;
  final List<String>? usernameMembers;
  final List<String> emails;
  final bool isAdmin;

  @override
  State<MembersTab> createState() => _MembersTabState();
}

class _MembersTabState extends State<MembersTab> {
  final TextEditingController membercontroller = TextEditingController();

  @override
  void dispose() {
    membercontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addProjectMemberCubit = BlocProvider.of<AddProjectMemberCubit>(
      context,
    );
    final theme = Theme.of(context);

    return BlocConsumer<DeleteMemberCubit, DeleteMemberState>(
      listener: (context, state) {
        if (state is DeleteMemberSuccess) {
          BlocProvider.of<ProjectCubit>(context).getOneProject(widget.id);

          customScafoldMessenger(
            context,
            'Member deleted successfully',
            color: Colors.green,
          );
          // We could trigger a refetch here if we had access to the list refresh cubit
        } else if (state is DeleteMemberError) {
          customScafoldMessenger(context, state.message, color: Colors.red);
        }
      },
      builder: (context, state) {
        return GlassPanel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Team Members',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    " (${widget.totalMembers})",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Add Member button (Admins only)
              if (widget.isAdmin) ...[
                GlassButton(
                  isOutlined: true,
                  icon: Icons.add,
                  label: 'Add Member',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) {
                        return BlocConsumer<
                          AddProjectMemberCubit,
                          AddProjectMemberState
                        >(
                          listener: (context, state) {
                            if (state is AddProjectMemberSuccess) {
                              BlocProvider.of<ProjectCubit>(
                                context,
                              ).getOneProject(widget.id);
                              // BlocProvider.of<GetUserProfileCubit>(
                              //   context,
                              // ).getUserProfile();
                              Navigator.pop(context);
                              customScafoldMessenger(
                                context,
                                'Member added successfully',
                                color: Colors.green,
                              );
                              membercontroller.clear();
                            }

                            if (state is AddProjectMemberError) {
                              Navigator.pop(context);
                              customScafoldMessenger(
                                context,
                                state.message,
                                color: Colors.red,
                              );
                            }
                          },
                          builder: (context, state) {
                            return ModalProgressHUD(
                              inAsyncCall: state is AddProjectMemberLoading,
                              child: AlertDialog(
                                backgroundColor: theme.colorScheme.surface,
                                title: const Text('Add Member'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const InputLabel(text: 'Member Name'),
                                    GlassInputField(
                                      hint: 'Enter member name',
                                      controller: membercontroller,
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      addProjectMemberCubit.addProjectMember(
                                        id: widget.id,
                                        usernameMember: membercontroller.text
                                            .trim(),
                                      );
                                    },
                                    child: const Text('Add'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Display Member usernames list
              if (widget.usernameMembers != null &&
                  widget.usernameMembers!.isNotEmpty) ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.usernameMembers!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final username = widget.usernameMembers![index];
                    final initials = username.isNotEmpty
                        ? username
                              .substring(
                                0,
                                username.length > 2 ? 2 : username.length,
                              )
                              .toUpperCase()
                        : 'M';

                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: theme.colorScheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                (widget.emails.isNotEmpty)
                                    ? widget.emails[index]
                                    : 'Project Contributor',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.isAdmin) ...[
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 28,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return AlertDialog(
                                      title: Text('Delete Member'.tr()),
                                      content: Text(
                                        'Are you sure you want to delete this member?'
                                            .tr(),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(dialogContext),
                                          child: Text('Cancel'.tr()),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(dialogContext);
                                            context
                                                .read<DeleteMemberCubit>()
                                                .deleteProjectMember(
                                                  id: widget.id,
                                                  usernameMember: username,
                                                );
                                          },
                                          child: Text(
                                            'Delete'.tr(),
                                            style: const TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ] else ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'No members listed.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
