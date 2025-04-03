import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/place_provider.dart';
import '../../components/suggested_place_card.dart';
import '../../components/place_details_sheet.dart';
import '../../services/user_service.dart';

class SuggestedPlacesPage extends StatelessWidget {
  SuggestedPlacesPage({super.key});

  final UserService _userService = UserService();

  void _showPlaceDetails(BuildContext context, place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailsSheet(
        place: place,
        onOpenInGoogleMaps: (lat, lng) async {
          final url = Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final places = context.watch<PlaceProvider>().places;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggested Places'),
      ),
      body: places.isEmpty
          ? const Center(
              child: Text('No places available'),
            )
          : ListView.builder(
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return FutureBuilder(
                  future: _userService.getUserById(place.addedBy),
                  builder: (context, snapshot) {
                    final addedByName =
                        snapshot.data?.fullName ?? 'Unknown User';
                    return SuggestedPlaceCard(
                      place: place,
                      addedByName: addedByName,
                      onTap: () => _showPlaceDetails(context, place),
                    );
                  },
                );
              },
            ),
    );
  }
}
