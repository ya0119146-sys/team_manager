import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:team_manager/features/auth/cubit/register_cubit/register_cubit.dart';

import 'package:team_manager/core/widgets/glass_input_field.dart';
import 'package:team_manager/core/widgets/glass_panel.dart';
import 'package:team_manager/core/widgets/glass_button.dart';
import 'package:team_manager/features/auth/widgets/input_label.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:team_manager/features/auth/screens/terms_and_privacy_screen.dart';

class SignUpCard extends StatefulWidget {
  const SignUpCard({super.key});
  @override
  State<SignUpCard> createState() => _SignUpCardState();
}

class _SignUpCardState extends State<SignUpCard> {
  bool isClicked = false;
  String role = "member";
  final formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController fullNameController = TextEditingController();

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Full name is required'.tr();
    return null;
  }



  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required'.tr();
    if (value.length < 3) return 'Username must be at least 3 characters'.tr();
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required'.tr();
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) return 'Enter a valid email address'.tr();
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Password is required'.tr();
    if (value.length < 6) return 'Password must be at least 6 characters'.tr();
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Confirm your password'.tr();
    if (value != passwordController.text) return 'Passwords do not match'.tr();
    return null;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RegisterCubit registerCubit = RegisterCubit.get(context);
    final theme = Theme.of(context);
    
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: GlassPanel(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create Account'.tr(),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign up for a new TeamManager account'.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 32),
              InputLabel(text: 'Full Name'.tr()),
              GlassInputField(
                controller: fullNameController,
                hint: 'Enter your full name'.tr(),
                validator: _validateFullName,
              ),
              const SizedBox(height: 14),
              InputLabel(text: 'Username'.tr()),
              GlassInputField(
                controller: usernameController,
                hint: 'Enter your username'.tr(),
                validator: _validateUsername,
              ),
              const SizedBox(height: 14),
              InputLabel(text: 'Email'.tr()),
              GlassInputField(
                controller: emailController,
                hint: 'Enter your email'.tr(),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 14),
              InputLabel(text: 'Password'.tr()),
              GlassInputField(
                controller: passwordController,
                hint: 'Enter your password'.tr(),
                obscure: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 14),
              InputLabel(text: 'Confirm Password'.tr()),
              GlassInputField(
                controller: confirmPasswordController,
                hint: 'Confirm your password'.tr(),
                obscure: true,
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Radio<String>(
                    value: "member",
                    groupValue: role,
                    onChanged: (value) => setState(() => role = value!),
                  ),
                  Text("Member".tr(), style: theme.textTheme.bodyMedium),
                  Radio<String>(
                    value: "admin",
                    groupValue: role,
                    onChanged: (value) => setState(() => role = value!),
                  ),
                  Text("Admin".tr(), style: theme.textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    value: isClicked,
                    onChanged: (_) {
                      setState(() {
                        isClicked = !isClicked;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'I agree to the'.tr(),
                          style: theme.textTheme.bodySmall,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TermsAndPrivacyScreen()),
                            );
                          },
                          child: Text(
                            'Terms of Service'.tr(),
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          'and'.tr(),
                          style: theme.textTheme.bodySmall,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TermsAndPrivacyScreen()),
                            );
                          },
                          child: Text(
                            'Privacy Policy'.tr(),
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GlassButton(
                label: 'Create Account'.tr(),
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    if (!isClicked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('You must agree to the Terms of Service'.tr())),
                      );
                      return;
                    }
                    registerCubit.register(
                      fullName: fullNameController.text,
                      username: usernameController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      confirmPassword: confirmPasswordController.text,
                      role: role,
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?".tr(), style: theme.textTheme.bodyMedium),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        GoRouter.of(context).pop();
                      },
                      child: Text('Sign in'.tr()),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}
