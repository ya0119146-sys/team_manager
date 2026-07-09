import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:team_manager/features/home/cubit/update_user_profile_cubit/update_user_profile_cubit.dart';
import 'package:team_manager/features/home/cubit/update_user_profile_cubit/update_user_profile_state.dart';
import 'package:team_manager/features/auth/model/profle_model.dart';
import 'package:team_manager/features/settings/widgets/save_button.dart';
import 'package:team_manager/features/auth/widgets/input_form_field.dart';
import 'package:team_manager/features/auth/widgets/input_label.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({super.key, required this.profileModel});
  final ProfileModel profileModel;
  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String role = '';

  @override
  void initState() {
    super.initState();
    fullNameController.text = widget.profileModel.fullName;
    userNameController.text = widget.profileModel.username;
    emailController.text = widget.profileModel.email;
    role = widget.profileModel.role;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    userNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UpdateUserProfileCubit updateUserProfileCubit =
        UpdateUserProfileCubit.get(context);
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<UpdateUserProfileCubit, UpdateUserProfileState>(
      listener: (context, state) {
        if (state is UpdateUserProfileSuccess) {
          customScafoldMessenger(
            context,
            "Profile updated successfully".tr(),
            color: Colors.green,
          );
        }
        if (state is UpdateUserProfileError) {
          customScafoldMessenger(
            context,
            state.error,
            color: theme.colorScheme.error,
          );
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: false,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    )
                  : theme.cardTheme.color ?? Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? theme.dividerColor.withValues(alpha: 0.1)
                    : theme.dividerColor,
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Information'.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update your personal details'.tr(),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                InputLabel(text: 'Full Name'.tr()),
                const SizedBox(height: 5),
                InputFormField(
                  hint: fullNameController.text,
                  prifixicon: const Icon(Icons.badge_outlined),
                  controller: fullNameController,
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                InputLabel(text: 'Username'.tr()),
                const SizedBox(height: 5),
                InputFormField(
                  hint: userNameController.text,
                  prifixicon: const Icon(Icons.person_outline),
                  controller: userNameController,
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                InputLabel(text: 'Email'.tr()),
                SizedBox(height: 5),
                InputFormField(
                  hint: emailController.text,
                  prifixicon: Icon(Icons.email_outlined),
                  controller: emailController,
                ),
                const SizedBox(height: 12),
                InputLabel(text: 'Role'.tr()),
                SizedBox(height: 5),
                InputFormField(
                  hint: role,
                  prifixicon: Icon(Icons.shield_outlined),
                  controller: TextEditingController(text: role),
                  readOnly: true,
                ),

                const SizedBox(height: 20),
                SaveButton(
                  onPressed: () {
                    updateUserProfileCubit.updateUserProfile(
                      emailController.text,
                    );
                  },
                  text: 'Save Changes'.tr(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
