import 'package:flutter/material.dart';
import 'package:walkwise/components/custom_button.dart';
import 'package:walkwise/components/custom_text_field.dart';

class RegisterSheet extends StatefulWidget {
  const RegisterSheet({super.key});

  @override
  State<RegisterSheet> createState() => _RegisterSheetState();
}

class _RegisterSheetState extends State<RegisterSheet> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
            'Register',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          CustomTextField(
            controller: _nameController,
            labelText: 'Full Name',
          ),
          const SizedBox(height: 24),
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
            text: 'Register',
            onPressed: () {
              // TODO: Implement register logic
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
