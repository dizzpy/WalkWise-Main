import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../components/custom_button.dart';
import '../../services/location_service.dart';
import '../../providers/user_provider.dart';
import '../navigations/dashboard.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  List<Place> _searchResults = [];
  Place? _selectedPlace;
  bool _isLoading = false;

  Future<void> _searchPlaces(String query) async {
    setState(() => _isLoading = true);
    try {
      final results = await _locationService.searchPlaces(query);
      setState(() => _searchResults = results);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLocationAndContinue() async {
    if (_selectedPlace == null) return;

    try {
      await context
          .read<UserProvider>()
          .updateLocation(_selectedPlace!.displayName);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to save location. Please try again.')),
        );
      }
    }
  }

  void _handleContinue() {
    if (_selectedPlace != null) {
      _saveLocationAndContinue();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Your Location',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search location...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  if (value.length >= 3) {
                    _searchPlaces(value);
                  }
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final place = _searchResults[index];
                          return ListTile(
                            title: Text(place.displayName),
                            onTap: () {
                              setState(() {
                                _selectedPlace = place;
                                _searchController.text = place.displayName;
                                _searchResults = [];
                              });
                            },
                          );
                        },
                      ),
              ),
              CustomButton(
                onPressed: _selectedPlace != null ? () => _handleContinue() : null,
                text: 'Continue',
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardPage(),
                      ),
                    );
                  },
                  child: const Text('Skip for now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
