import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_manager/core/helpers/cache_helper.dart';
import 'package:team_manager/core/helpers/secure_storage_helper.dart';
import 'package:team_manager/core/utils/app_router.dart';
import 'package:team_manager/features/home/cubit/delete_user_profile_cubit/delete_user_profile_cubit.dart';
import 'package:team_manager/features/home/cubit/delete_user_profile_cubit/delete_user_profile_state.dart';
import 'package:team_manager/features/settings/cubits/change_passwordcubit/change_password_cubit.dart';
import 'package:team_manager/features/settings/cubits/change_passwordcubit/change_password_state.dart';
import 'package:team_manager/features/settings/widgets/save_button.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:easy_localization/easy_localization.dart';

class SecuritySettings extends StatefulWidget {
  const SecuritySettings({super.key});

  @override
  State<SecuritySettings> createState() => _SecuritySettingsState();
}

class _SecuritySettingsState extends State<SecuritySettings> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ChangePasswordCubit>().changePassword(
      oldPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    DeleteUserProfileCubit deleteUserProfileCubit = DeleteUserProfileCubit.get(
      context,
    );
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, changePasswordState) {
        if (changePasswordState is ChangePasswordSuccess) {
          customScafoldMessenger(
            context,
            'Password changed successfully! Please login again.'.tr(),
            color: Colors.green,
          );
          GoRouter.of(context).pushReplacement(AppRouter.kLoginScreen);
        } else if (changePasswordState is ChangePasswordError) {
          customScafoldMessenger(
            context,
            changePasswordState.error,
            color: Colors.red,
          );
        }
      },
      builder: (context, changePasswordState) {
        return BlocConsumer<DeleteUserProfileCubit, DeleteUserProfileState>(
          listener: (context, deleteState) {
            if (deleteState is DeleteUserProfileSuccess) {
              customScafoldMessenger(
                context,
                "Profile deleted successfully".tr(),
                color: Colors.green,
              );
              SecureStorageHelper.deleteToken();
              CacheHelper.setBool(key: 'auth_active', value: false);
              CacheHelper.removeData(key: 'role');
              GoRouter.of(context).pushReplacement(AppRouter.kLoginScreen);
            }
            if (deleteState is DeleteUserProfileError) {
              customScafoldMessenger(
                context,
                deleteState.error,
                color: theme.colorScheme.error,
              );
            }
          },
          builder: (context, deleteState) {
            final isLoading =
                changePasswordState is ChangePasswordLoading ||
                deleteState is DeleteUserProfileLoading;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.12),
                ),
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Settings'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Update your security settings'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 1. Current Password
                        Text(
                          'Current Password'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _currentPasswordController,
                          obscureText: _obscureCurrent,
                          style: theme.textTheme.bodyMedium,
                          decoration: _getInputDecoration(
                            theme: theme,
                            isDark: isDark,
                            hintText: 'Enter current password'.tr(),
                            isObscured: _obscureCurrent,
                            onToggleObscure: () {
                              setState(() {
                                _obscureCurrent = !_obscureCurrent;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Current password is required'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // 2. New Password
                        Text(
                          'New Password'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _newPasswordController,
                          obscureText: _obscureNew,
                          style: theme.textTheme.bodyMedium,
                          decoration: _getInputDecoration(
                            theme: theme,
                            isDark: isDark,
                            hintText: 'Enter new password'.tr(),
                            isObscured: _obscureNew,
                            onToggleObscure: () {
                              setState(() {
                                _obscureNew = !_obscureNew;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'New password is required'.tr();
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters long'
                                  .tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // 3. Confirm New Password
                        Text(
                          'Confirm New Password'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirm,
                          style: theme.textTheme.bodyMedium,
                          decoration: _getInputDecoration(
                            theme: theme,
                            isDark: isDark,
                            hintText: 'Confirm your new password'.tr(),
                            isObscured: _obscureConfirm,
                            onToggleObscure: () {
                              setState(() {
                                _obscureConfirm = !_obscureConfirm;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please confirm your password'.tr();
                            }
                            if (value != _newPasswordController.text) {
                              return 'Passwords do not match'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Actions Buttons
                        Row(
                          children: [
                            Expanded(
                              child: SaveButton(
                                onPressed: _changePassword,
                                text: 'Change Password'.tr(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.error,
                              side: BorderSide(
                                color: theme.colorScheme.error.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.error
                                                .withValues(alpha: 0.1),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme.error
                                                  .withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.warning_rounded,
                                              color: theme.colorScheme.error,
                                              size: 32,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            'Delete Account'.tr(),
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      theme.colorScheme.error,
                                                ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.'
                                                .tr(),
                                            textAlign: TextAlign.center,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: theme.hintColor,
                                                ),
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 14,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text(
                                                    'Cancel'.tr(),
                                                    style: TextStyle(
                                                      color: theme.hintColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        theme.colorScheme.error,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 14,
                                                        ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    elevation: 0,
                                                  ),
                                                  onPressed: () {
                                                    deleteUserProfileCubit
                                                        .deleteUserProfile();
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    'Delete'.tr(),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: Text(
                              'Delete Account'.tr(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.65,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _getInputDecoration({
    required ThemeData theme,
    required bool isDark,
    required String hintText,
    required bool isObscured,
    required VoidCallback onToggleObscure,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
        alpha: isDark ? 0.3 : 0.6,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
        ),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isObscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20,
          color: theme.hintColor,
        ),
        onPressed: onToggleObscure,
      ),
    );
  }
}
