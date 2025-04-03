import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/place_provider.dart';
import '../../components/suggested_place_card.dart';
import '../../constants/colors.dart';
import '../../components/place_details_sheet.dart';

class SearchPlacesPage extends StatefulWidget {
  const SearchPlacesPage({super.key});

  @override
  State<SearchPlacesPage> createState() => _SearchPlacesPageState();
}

class _SearchPlacesPageState extends State<SearchPlacesPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPlaceDetails(place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceDetailsSheet(
        place: place,
        onOpenInGoogleMaps: (lat, lng) async {
          // Handle maps opening
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(fontSize: 15),
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search places...',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
            ),
            prefixIcon: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ),
      body: Consumer<PlaceProvider>(
        builder: (context, provider, _) {
          final places = provider.places.where((place) {
            if (_searchQuery.isEmpty) return false;
            return place.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                place.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                place.tags.any((tag) =>
                    tag.toLowerCase().contains(_searchQuery.toLowerCase()));
          }).toList();

          if (_searchQuery.isEmpty) {
            return const Center(
              child: Text('Start typing to search places'),
            );
          }

          if (places.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No places found',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              return SuggestedPlaceCard(
                place: place,
                addedByName: 'Someone',
                onTap: () => _showPlaceDetails(place),
              );
            },
          );
        },
      ),
    );
  }
}
