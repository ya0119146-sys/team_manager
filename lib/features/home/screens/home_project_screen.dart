import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_cubit.dart';
import 'package:team_manager/features/home/cubit/get_all_project_cubit/project_state.dart';
import 'package:team_manager/features/home/models/project_model.dart';
import 'package:team_manager/features/home/widgets/create_new_project_dialog.dart';
import 'package:team_manager/features/home/widgets/project_card.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:team_manager/core/widgets/glass_input_field.dart';
import 'package:team_manager/core/widgets/empty_state_widget.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeProjectScreen extends StatefulWidget {
  const HomeProjectScreen({super.key, required this.isAdmin});
  final bool isAdmin;
  @override
  State<HomeProjectScreen> createState() => _HomeProjectScreenState();
}

class _HomeProjectScreenState extends State<HomeProjectScreen> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProjectCubit>().getProjects();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<ProjectModel> _filterProjects(List<ProjectModel> projects) {
    final query = searchController.text.trim().toLowerCase();
    if (query.isEmpty) return projects;
    return projects.where((project) {
      return project.name.toLowerCase().contains(query) ||
          project.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: BlocBuilder<ProjectCubit, ProjectState>(
        builder: (context, state) {
          List<ProjectModel> projects = [];

          if (state is ProjectSuccessState) {
            projects = state.projects;
          }

          final filtered = _filterProjects(projects);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Projects'.tr(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  '${filtered.length}${' projects'.tr()}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),

                const SizedBox(height: 12),
                if (widget.isAdmin)
                  SizedBox(
                    width: double.infinity,
                    child: GlassButton(
                      label: '+ New Project'.tr(),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => const CreateProjectDialog(),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 12),

                GlassInputField(
                  hint: 'Search projects...'.tr(),
                  controller: searchController,
                  prefixIcon: Icons.search,
                  onChanged: (_) {
                    setState(() {});
                  },
                ),

                const SizedBox(height: 16),

                if (state is ProjectLoadingState)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state is ProjectErrorState)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                else if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: EmptyStateWidget(
                      icon: Icons.folder_open_outlined,
                      title: 'No projects found'.tr(),
                      subtitle: 'Create a project or adjust your search query.'
                          .tr(),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return ProjectCard(
                        project: filtered[index],
                        isAdmin: widget.isAdmin,
                        index: index,
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
