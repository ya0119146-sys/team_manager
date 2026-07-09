import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:team_manager/core/utils/app_router.dart';
import 'package:team_manager/features/auth/cubit/forget_password_cubit/forget_password_cubit.dart';
import 'package:team_manager/features/auth/cubit/forget_password_cubit/forget_password_state.dart';
import 'package:team_manager/features/auth/cubit/verify_code_register_cubit/verify_code_state.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:team_manager/features/auth/widgets/header.dart';
import 'package:team_manager/features/auth/widgets/input_label.dart';
import 'package:easy_localization/easy_localization.dart';

class ForgetPasswordScreen2 extends StatefulWidget {
  const ForgetPasswordScreen2({super.key});
  @override
  State<ForgetPasswordScreen2> createState() => _ForgetPasswordScreen2State();
}

class _ForgetPasswordScreen2State extends State<ForgetPasswordScreen2> {
  String otpCode = '';

  @override
  Widget build(BuildContext context) {
    final forgetPasswordCubit = ForgetPasswordCubit.get(context);

    return BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
      listener: (context, state) {
        if (state is ForgetPasswordSuccess) {
          customScafoldMessenger(
            context,
            'Verification successful'.tr(),
            color: Colors.green,
          );
          GoRouter.of(
            context,
          ).pushReplacement(AppRouter.kForgotPasswordScreen3);
        } else if (state is ForgetPasswordError) {
          customScafoldMessenger(context, state.message, color: Colors.red);
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: state is ForgetPasswordLoading,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Header(title: 'verify your identity'.tr()),
                    Card(
                      color: Colors.white,
                      margin: const EdgeInsets.all(16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verify OTP'.tr(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Enter the 6-digit code sent to you'.tr(),
                              style: const TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 20),
                            InputLabel(text: 'Enter 6-digit OTP'.tr()),
                            const SizedBox(height: 12),

                            /// ✅ OTP FIELD
                            OtpTextField(
                              numberOfFields: 6,
                              borderColor: Colors.black,
                              focusedBorderColor: Colors.black,
                              showFieldAsBox: true,
                              fieldWidth: 45,
                              borderRadius: BorderRadius.circular(8),
                              onCodeChanged: (code) {
                                otpCode = code;
                              },
                              onSubmit: (code) {
                                otpCode = code; // ✅ مضمون
                              },
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: state is VerifyCodeLoadingState
                                    ? null
                                    : () {
                                        if (otpCode.length != 6) {
                                          customScafoldMessenger(
                                            context,
                                            'Please enter complete OTP'.tr(),
                                            color: Colors.red,
                                          );
                                          return;
                                        }

                                        forgetPasswordCubit.verifyResetCode(
                                          verifyCode: otpCode,
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                ),
                                child: Text(
                                  'Verify OTP'.tr(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Center(
                              child: TextButton(
                                onPressed: () => GoRouter.of(context).pop(),
                                child: Text(
                                  'Back'.tr(),
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
