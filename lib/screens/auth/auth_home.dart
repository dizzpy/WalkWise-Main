import 'package:flutter/material.dart';
import 'package:walkwise/components/custom_button.dart';

class AuthHome extends StatelessWidget {
  const AuthHome({super.key});

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
                onPressed: () {
                  // TODO: Implement login navigation
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Register',
                onPressed: () {
                  // TODO: Implement register navigation
                },
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
