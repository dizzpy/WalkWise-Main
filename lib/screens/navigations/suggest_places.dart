import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:walkwise/constants/colors.dart';
import 'package:walkwise/screens/navigations/add_place_page.dart';

class SuggestPlaces extends StatelessWidget {
  const SuggestPlaces({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Locations'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the Add Location page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlacePage()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      body: const Center(
        child: Text('Welcome to the Suggest Places Page !'),
      ),
    );
  }
}
