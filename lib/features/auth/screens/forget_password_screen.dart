import 'package:flutter/material.dart';
import 'package:team_manager/features/auth/widgets/header.dart';
import 'package:team_manager/features/auth/widgets/forget_password_card.dart';
import 'package:easy_localization/easy_localization.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? size.width * 0.2 : 20,
            vertical: 24,
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Header(title: 'Reset your password'.tr()),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: const ForgetPasswordCard(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
