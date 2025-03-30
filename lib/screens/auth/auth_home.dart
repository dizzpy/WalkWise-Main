import 'package:flutter/material.dart';
import 'package:walkwise/components/custom_button.dart';
import 'package:walkwise/screens/auth/login_sheet.dart';
import 'package:walkwise/screens/auth/register_sheet.dart';

class AuthHome extends StatelessWidget {
  const AuthHome({super.key});

  void _showLoginSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const LoginSheet(),
    );
  }

  void _showRegisterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const RegisterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // Logo and Welcome Text
              Center(
                child: Column(
                  children: [
                    Text(
                      'WalkWise',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your walking companion',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              // Auth Buttons
              CustomButton(
                text: 'Login',
                onPressed: () => _showLoginSheet(context),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Register',
                onPressed: () => _showRegisterSheet(context),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
