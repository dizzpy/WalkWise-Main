import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:walkwise/constants/colors.dart';
import 'package:walkwise/components/search_field.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final username = "Dizzpy"; // You can fetch this from your AuthProvider later

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting + Notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hey $username",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text("Good Morning", style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
                color: AppColors.text,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Search
          const SearchField(),

          const SizedBox(height: 24),

          // Recent Places
          Text(
            "Recent Places",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),

          Column(
            children: List.generate(3, (_) => _buildRecentPlaceCard()),
          ),

          const SizedBox(height: 24),

          // Map View
          Text(
            "Map View",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FlutterMap(
                options: MapOptions(
                  center: LatLng(7.8731, 80.7718), // 🇱🇰 Sri Lanka
                  zoom: 7.5,
                  minZoom: 6.0,
                  maxZoom: 15.0,
                  interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                  maxBounds: LatLngBounds(
                    LatLng(5.7, 79.6),  // Southwest bound
                    LatLng(9.9, 82.1),  // Northeast bound
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.walkwise',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPlaceCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Place Name", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
              Text("2km Near", style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
