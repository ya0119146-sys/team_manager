import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:team_manager/core/utils/app_router.dart';
import 'package:team_manager/features/auth/cubit/forget_password_cubit/forget_password_cubit.dart';
import 'package:team_manager/features/auth/cubit/forget_password_cubit/forget_password_state.dart';
import 'package:team_manager/core/widgets/glass_input_field.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:team_manager/features/auth/widgets/input_label.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:easy_localization/easy_localization.dart';

class ForgetPasswordCard extends StatefulWidget {
  const ForgetPasswordCard({super.key});

  @override
  State<ForgetPasswordCard> createState() => _ForgetPasswordCardState();
}

class _ForgetPasswordCardState extends State<ForgetPasswordCard> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required'.tr();
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) return 'Enter a valid email address'.tr();
    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forgetPasswordCubit = ForgetPasswordCubit.get(context);
    final theme = Theme.of(context);

    return BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
      listener: (context, state) {
        if (state is ForgetPasswordSuccess) {
          GoRouter.of(context).push(AppRouter.kForgetPasswordScreen2);
        } else if (state is ForgetPasswordError) {
          customScafoldMessenger(
            context,
            state.message,
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forget password?'.tr(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the email associated with your account'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),

                InputLabel(text: 'Email Address'.tr()),
                GlassInputField(
                  controller: emailController,
                  hint: 'Enter your email'.tr(),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),

                const SizedBox(height: 16),
                Text(
                  'We\'ll send you a one-time password to verify your identity'.tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),

                const SizedBox(height: 24),
                GlassButton(
                  label: 'Send OTP'.tr(),
                  isLoading: state is ForgetPasswordLoading,
                  onPressed: state is ForgetPasswordLoading
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            forgetPasswordCubit.resetCode(
                              email: emailController.text,
                            );
                          }
                        },
                ),

                const SizedBox(height: 32),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => GoRouter.of(context).pop(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Back to login'.tr(),
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
