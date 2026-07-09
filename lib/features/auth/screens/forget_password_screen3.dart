import 'package:flutter/material.dart';
import 'package:team_manager/features/auth/widgets/header.dart';
import 'package:team_manager/features/auth/widgets/reset_password_card.dart';

class ForgetPasswordScreen3 extends StatelessWidget {
  const ForgetPasswordScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
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
                Header(title: 'Reset your password'),
                const SizedBox(height: 32),
                const ResetPasswordCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
