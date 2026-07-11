import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:team_manager/core/utils/app_router.dart';
import 'package:team_manager/features/auth/cubit/auth_cubit/login_cubit.dart';
import 'package:team_manager/core/widgets/glass_input_field.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:team_manager/features/auth/widgets/input_label.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  bool isClicked = false;
  bool isPasswordObscured = true;
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required'.tr();
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) return 'Enter a valid email address'.tr();
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required'.tr();
    }
    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    LoginCubit authCubit = LoginCubit.get(context);
    final theme = Theme.of(context);

    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back'.tr(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to your account to continue'.tr(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 20),
              InputLabel(text: 'Email'.tr()),
              GlassInputField(
                controller: emailController,
                hint: 'Enter your email'.tr(),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                validator: _validateEmail,
              ),
              const SizedBox(height: 14),
              InputLabel(text: 'Password'.tr()),
              GlassInputField(
                controller: passwordController,
                hint: 'Enter your password'.tr(),
                obscure: isPasswordObscured,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordObscured
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordObscured = !isPasswordObscured;
                    });
                  },
                ),
                autofillHints: const [AutofillHints.password],
                validator: _validatePassword,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // Checkbox(
                  //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  //   value: isClicked,
                  //   onChanged: (_) {
                  //     setState(() {
                  //       isClicked = !isClicked;
                  //     });
                  //   },
                  // ),
                  // Text('Remember me'.tr(), style: theme.textTheme.bodySmall),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      GoRouter.of(
                        context,
                      ).push(AppRouter.kForgotPasswordScreen);
                    },
                    child: Text(
                      'Forgot password?'.tr(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GlassButton(
                label: 'Sign In'.tr(),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    authCubit.login(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              // Row(
              //   children: [
              //     Expanded(child: OutlinedBtn(text: 'Login as Admin')),
              //     const SizedBox(width: 12),
              //     Expanded(child: OutlinedBtn(text: 'Login as Member')),
              //   ],
              // ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?".tr(),
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        GoRouter.of(context).push(AppRouter.kSignUpScreen);
                      },
                      child: Text('Sign up'.tr()),
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
