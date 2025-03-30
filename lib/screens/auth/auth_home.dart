import 'package:flutter/material.dart';

class AuthHome extends StatelessWidget {
  const AuthHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome to the Authentication Home!'),
            ElevatedButton(
              onPressed: () {
                // Navigate to login screen
              },
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to signup screen
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
