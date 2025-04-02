import 'package:flutter/material.dart';

class SuggestPlaces extends StatelessWidget {
  const SuggestPlaces({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggest Places'),
      ),
      body: const Center(
        child: Text('Welcome to the Suggest Places Page !'),
      ),
    );
  }
}
