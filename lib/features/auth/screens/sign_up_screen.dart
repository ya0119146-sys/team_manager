import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:team_manager/core/utils/app_router.dart';
import 'package:team_manager/features/auth/cubit/register_cubit/register_cubit.dart';
import 'package:team_manager/features/auth/cubit/register_cubit/register_state.dart';
import 'package:team_manager/features/auth/widgets/header.dart';
import 'package:team_manager/features/auth/widgets/sign_up_card.dart';
import 'package:team_manager/features/auth/widgets/custom_scafold_messanger.dart';
import 'package:easy_localization/easy_localization.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          customScafoldMessenger(context, state.message, color: Colors.green);
          GoRouter.of(context).push(AppRouter.kVerfiyCodeRegisterScreen);
        } else if (state is RegisterError) {
          customScafoldMessenger(context, state.message, color: Colors.red);
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: state is RegisterLoading,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? size.width * 0.2 : 20,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Header(title: 'Create your account to get started'.tr()),
                      const SizedBox(height: 32),
                      const SignUpCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
