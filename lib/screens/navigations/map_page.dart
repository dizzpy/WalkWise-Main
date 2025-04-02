import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:walkwise/screens/places/add_place_page.dart';
import '../../providers/user_provider.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  Widget _buildMapView() {
    final user = context.watch<UserProvider>().user;
    final userLocation = user?.latitude != null && user?.longitude != null
        ? LatLng(user!.latitude!, user.longitude!)
        : LatLng(6.901022685210251, 81.34012272850336); // Default coordinates

    // Sri Lanka's approximate bounds
    final sriLankaBounds = LatLngBounds(
      LatLng(5.916667, 79.516667),
      LatLng(9.850000, 81.900000),
    );

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: userLocation,
            initialZoom: 15.0,
            minZoom: 7.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            cameraConstraint: CameraConstraint.contain(bounds: sriLankaBounds),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: userLocation,
                  width: 50,
                  height: 50,
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
          bottom: 100, // Increased spacing
          child: FloatingActionButton(
            heroTag: "btn1", // Add hero tags to prevent conflicts
            backgroundColor: Colors.black,
            onPressed: () {
              _mapController.move(userLocation, 15.0);
            },
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: "btn2",
            backgroundColor: Colors.black,
            onPressed: () {
              // Temporarily show a snackbar until AddPlacePage is implemented
              // ScaffoldMessenger.of(context).showSnackBar(
              //   const SnackBar(
              //     content: Text('Add Place feature coming soon!'),
              //   ),
              // );
              // Uncomment this when AddPlacePage is ready
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPlacePage(),
                ),
              );
            },
            child: const Icon(
              Icons.add_location_alt,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: _buildMapView(),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
