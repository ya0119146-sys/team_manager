import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_manager/core/helpers/secure_storage_helper.dart';
import 'package:team_manager/core/utils/app_router.dart';
import 'package:team_manager/features/auth/cubit/forget_password_cubit/forget_password_cubit.dart';
import 'package:team_manager/features/auth/cubit/forget_password_cubit/forget_password_state.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:team_manager/core/widgets/glass_input_field.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:team_manager/features/auth/widgets/input_label.dart';
import 'package:easy_localization/easy_localization.dart';

class ResetPasswordCard extends StatefulWidget {
  const ResetPasswordCard({super.key});

  @override
  State<ResetPasswordCard> createState() => _ResetPasswordCardState();
}

class _ResetPasswordCardState extends State<ResetPasswordCard> {
  final formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required'.tr();
    if (value.length < 6) return 'Password must be at least 6 characters'.tr();
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Confirm your password'.tr();
    if (value != newPasswordController.text) return 'Passwords do not match'.tr();
    return null;
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ForgetPasswordCubit forgetPasswordCubit = ForgetPasswordCubit.get(context);
    final theme = Theme.of(context);

    return BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
      listener: (context, state) {
        if (state is ForgetPasswordSuccess) {
          customScafoldMessenger(
            context,
            'Password changed successfully'.tr(),
            color: Colors.green,
          );

          GoRouter.of(context).pushReplacement(AppRouter.kLoginScreen);

          SecureStorageHelper.deleteToken();
        } else if (state is ForgetPasswordError) {
          customScafoldMessenger(
            context,
            'Failed to change password'.tr(),
            color: theme.colorScheme.error,
          );
        }
      },
      builder: (context, state) {
        return GlassPanel(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset password?'.tr(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a strong password to secure your account'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),
                
                InputLabel(text: 'New Password'.tr()),
                GlassInputField(
                  controller: newPasswordController,
                  hint: 'Enter your new password'.tr(),
                  obscure: true,
                  validator: _validatePassword,
                ),
                
                const SizedBox(height: 16),
                
                InputLabel(text: 'Confirm Password'.tr()),
                GlassInputField(
                  controller: confirmPasswordController,
                  hint: 'Confirm your new password'.tr(),
                  obscure: true,
                  validator: _validateConfirmPassword,
                ),
                
                const SizedBox(height: 24),
                GlassButton(
                  label: 'Reset Password'.tr(),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      forgetPasswordCubit.changePassword(
                        newPassword: newPasswordController.text,
                        confirmPassword: confirmPasswordController.text,
                      );
                    }
                  },
                ),
                
                const SizedBox(height: 32),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    GoRouter.of(context).pushReplacement(AppRouter.kLoginScreen);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Cancel and return to login'.tr(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
