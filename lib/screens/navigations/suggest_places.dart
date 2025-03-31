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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Places').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final places = snapshot.data?.docs ?? [];

          if (places.isEmpty) {
            return const Center(child: Text("No places found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index].data() as Map<String, dynamic>;
              return _buildPlaceCard(place);
            },
          );
        },
      ),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            place['placeName'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            (place['createdAt'] as Timestamp?)?.toDate().toString().split(' ').first ?? '',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 8,
                children: const [
                  Chip(label: Text("📝 Review")),
                  Chip(label: Text("🚩 Report")),
                  Chip(label: Text("📍 Guide")),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  Text(" ${place['rating']?.toStringAsFixed(1) ?? "0.0"}"),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
