import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../models/place_model.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../providers/user_provider.dart';
import '../providers/place_provider.dart';
import 'report_place_dialog.dart';
import '../services/report_service.dart';

class PlaceDetailsSheet extends StatefulWidget {
  final PlaceModel place;
  final Function(double lat, double lng) onOpenInGoogleMaps;

  const PlaceDetailsSheet({
    super.key,
    required this.place,
    required this.onOpenInGoogleMaps,
  });

  @override
  State<PlaceDetailsSheet> createState() => _PlaceDetailsSheetState();
}

class _PlaceDetailsSheetState extends State<PlaceDetailsSheet> {
  final UserService _userService = UserService();
  final ReportService _reportService = ReportService();
  UserModel? _addedByUser;
  bool _isLoadingUser = true;
  bool _canReport = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _trackView();
    _checkReportEligibility();
  }

  Future<void> _loadUserDetails() async {
    try {
      final user = await _userService.getUserById(widget.place.addedBy);
      setState(() {
        _addedByUser = user;
        _isLoadingUser = false;
      });
    } catch (e) {
      setState(() => _isLoadingUser = false);
      print('Error loading user details: $e');
    }
  }

  Future<void> _trackView() async {
    final user = context.read<UserProvider>().user;
    if (user != null) {
      await context.read<PlaceProvider>().addToLastViewed(
            user.id,
            widget.place.id,
          );
    }
  }

  Future<void> _checkReportEligibility() async {
    final user = context.read<UserProvider>().user;
    if (user != null) {
      // User can't report their own places
      if (widget.place.addedBy == user.id) {
        setState(() => _canReport = false);
        return;
      }

      // Check if user has already reported this place
      final hasReported = await _reportService.hasUserReportedPlace(
        placeId: widget.place.id,
        userId: user.id,
      );
      setState(() => _canReport = !hasReported);
    }
  }

  void _showReportDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReportPlaceDialog(
        placeId: widget.place.id,
        placeName: widget.place.name,
        userId: context.read<UserProvider>().user!.id,
      ),
    ).then((reported) {
      if (reported == true) {
        setState(() => _canReport = false);
      }
    });
  }

  Widget _buildAddedByText() {
    if (_isLoadingUser) {
      return const Text('Loading...', style: TextStyle(color: Colors.grey));
    }
    return Text(
      'Added by ${_addedByUser?.fullName ?? 'Unknown User'}',
      style: TextStyle(color: Colors.grey[700]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Place name
                    Text(
                      widget.place.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Address
                    Text(
                      widget.place.address,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tags
                    if (widget.place.tags.isNotEmpty) ...[
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: widget.place.tags
                              .map((tag) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Chip(
                                      label: Text(tag),
                                      backgroundColor: Colors.grey[100],
                                      side: BorderSide.none,
                                      labelStyle: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Added by and date info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildAddedByText(),
                          ),
                          Text(
                            timeago.format(widget.place.addedDate),
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Description
                    const Text(
                      'About this place',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.place.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Reviews section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reviews',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement review feature
                          },
                          child: const Text('Add Review'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'No reviews yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Google Maps button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => widget.onOpenInGoogleMaps(
                          widget.place.latitude,
                          widget.place.longitude,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.map, color: Colors.white),
                        label: const Text(
                          'Open in Google Maps',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    if (_canReport)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showReportDialog,
                          icon: const Icon(Icons.report_problem_outlined),
                          label: const Text('Report this place'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[50],
                            foregroundColor: Colors.red[700],
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.red[200]!),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
