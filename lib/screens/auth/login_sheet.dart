import 'package:flutter/material.dart';
import 'package:walkwise/components/custom_button.dart';
import 'package:walkwise/components/custom_text_field.dart';

class LoginSheet extends StatefulWidget {
  const LoginSheet({super.key});

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 32,
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Login',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          CustomTextField(
            controller: _emailController,
            labelText: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _passwordController,
            labelText: 'Password',
          ),
          const Spacer(),
          CustomButton(
            text: 'Login',
            onPressed: () {
              // TODO: Implement login logic
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
