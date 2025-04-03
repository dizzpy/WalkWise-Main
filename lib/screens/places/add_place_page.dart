import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../components/custom_button.dart';
import '../../components/custom_text_field.dart';
import '../../providers/user_provider.dart';
import '../../providers/place_provider.dart';
import 'location_picker_page.dart';
import '../../models/place_model.dart';

class AddPlacePage extends StatefulWidget {
  const AddPlacePage({super.key});

  @override
  State<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tagsController = TextEditingController();
  final _descriptionController = TextEditingController();
  LatLng? _selectedLocation;
  String? _selectedLocationName;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _tagsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _savePlaceData() async {
    if (!_formKey.currentState!.validate() || _selectedLocation == null) return;

    setState(() => _isLoading = true);

    try {
      final user = context.read<UserProvider>().user;
      if (user == null) throw Exception('User not logged in');

      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final place = PlaceModel(
        id: '', // Will be set by Firestore
        name: _nameController.text,
        description: _descriptionController.text,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        tags: tags,
        addedBy: user.id,
        addedDate: DateTime.now(),
        address: _selectedLocationName ?? '',
      );

      await context.read<PlaceProvider>().addPlace(place);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Place added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding place: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildLocationSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedLocationName ?? 'No location selected',
            style: TextStyle(
              color: _selectedLocationName != null ? Colors.black : Colors.grey,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            onPressed: () async {
              final result = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationPickerPage(),
                ),
              );

              if (result != null) {
                setState(() {
                  _selectedLocation = result['location'] as LatLng;
                  _selectedLocationName = result['address'] as String;
                });
              }
            },
            text:
                _selectedLocation == null ? 'Pick Location' : 'Change Location',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Place'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Place Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _nameController,
                labelText: 'Enter place name',
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a place name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Tags',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _tagsController,
                labelText: 'E.g., restaurant, coffee, wifi',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              const Text(
                'Added By',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  context.read<UserProvider>().user?.fullName ?? "Unknown",
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Enter place description',
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              _buildLocationSelector(),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: _selectedLocation == null || _isLoading
                    ? null
                    : _savePlaceData,
                text: _isLoading ? 'Adding Place...' : 'Add Place',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
