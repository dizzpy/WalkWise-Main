import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:walkwise/constants/colors.dart';

class AddPlacePage extends StatefulWidget {
  const AddPlacePage({super.key});

  @override
  State<AddPlacePage> createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _placeName = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _tags = TextEditingController();

  String? _addedBy;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('Users').doc(uid).get();
      setState(() {
        _addedBy = doc.data()?['fullName'] ?? 'Unknown';
      });
    }
  }

  void _pickLocation() {
    // Hardcoded for now. Replace with a map picker later.
    setState(() {
      _selectedLocation = const LatLng(7.8731, 80.7718); // Center of Sri Lanka
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_addedBy == null) return;

    final List<String> tagList = _tags.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    await FirebaseFirestore.instance.collection('Places').add({
      'placeName': _placeName.text.trim(),
      'description': _description.text.trim(),
      'tags': tagList,
      'addedBy': _addedBy,
      'createdAt': FieldValue.serverTimestamp(),
      'location': _selectedLocation != null
          ? GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude)
          : null,
      'rating': 0.0,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_addedBy == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Location"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Place Name", _placeName),
              const SizedBox(height: 16),
              _buildTextField("Add Tags (comma separated)", _tags),
              const SizedBox(height: 16),
              _buildDisabledField("Added By", _addedBy!),
              const SizedBox(height: 16),
              _buildTextField("Description About Place", _description, maxLines: 5),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickLocation,
                icon: const Icon(Icons.location_on),
                label: Text(_selectedLocation != null
                    ? "Location Selected"
                    : "Pick Your Location"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Add Location"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (val) => val == null || val.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDisabledField(String label, String value) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
