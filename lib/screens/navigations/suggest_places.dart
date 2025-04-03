import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/place_provider.dart';
import '../../services/user_service.dart';
import '../../components/suggested_place_card.dart';
import '../../components/place_details_sheet.dart';
import '../../components/skeleton_loading.dart';

class SuggestPlaces extends StatefulWidget {
  const SuggestPlaces({super.key});

  @override
  State<SuggestPlaces> createState() => _SuggestPlacesState();
}

class _SuggestPlacesState extends State<SuggestPlaces> {
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    await context.read<PlaceProvider>().loadPlaces();
  }

  void _showPlaceDetails(place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailsSheet(
        place: place,
        onOpenInGoogleMaps: (lat, lng) async {
          final url = Uri.parse(
              'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
          try {
            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open Google Maps')),
                );
              }
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error opening Google Maps')),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                SkeletonLoading(
                  width: 50,
                  height: 50,
                  borderRadius: 12,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoading(
                        width: 140,
                        height: 20,
                        borderRadius: 4,
                      ),
                      SizedBox(height: 8),
                      SkeletonLoading(
                        width: 180,
                        height: 16,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: const SkeletonLoading(
                    width: 60,
                    height: 24,
                    borderRadius: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const SkeletonLoading(
              width: 120,
              height: 16,
              borderRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggested Places'),
      ),
      body: Consumer<PlaceProvider>(
        builder: (context, placeProvider, child) {
          if (placeProvider.loading) {
            return _buildLoadingState();
          }

          final places = placeProvider.places;

          if (places.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.place_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No places available',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adding some places to get started',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => placeProvider.loadPlaces(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                      onTap: () => _showPlaceDetails(place),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
