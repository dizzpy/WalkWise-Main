import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/location_service.dart';
import '../../components/custom_button.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  LatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    final user = context.read<UserProvider>().user;
    if (user?.latitude != null && user?.longitude != null) {
      _moveToLocation(LatLng(user!.latitude!, user.longitude!));
    }
  }

  void _moveToLocation(LatLng location) {
    _mapController.move(location, 15.0);
  }

  Future<void> _getAddressForLocation(LatLng location) async {
    setState(() => _isLoading = true);
    try {
      final address = await _locationService.getLocationNameFromCoords(
        location.latitude,
        location.longitude,
      );
      setState(() => _selectedAddress = address);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final userLocation = user?.latitude != null && user?.longitude != null
        ? LatLng(user!.latitude!, user.longitude!)
        : LatLng(7.873054, 80.771797);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: userLocation,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                setState(() => _selectedLocation = point);
                _getAddressForLocation(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  if (_selectedLocation != null)
                    Marker(
                      point: _selectedLocation!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  // User's current location
                  Marker(
                    point: userLocation,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(0.3),
                      ),
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () => _moveToLocation(userLocation),
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          if (_selectedLocation != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_selectedAddress != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _selectedAddress!,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: CustomButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context, {
                                'location': _selectedLocation,
                                'address': _selectedAddress,
                              });
                            },
                      text: 'Confirm Location',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
