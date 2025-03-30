import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkwise/providers/auth_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome to Dashboard!'),
      ),
    );
  }
}
