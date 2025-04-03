import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../models/place_model.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../providers/user_provider.dart';
import '../providers/place_provider.dart';
import '../providers/review_provider.dart';
import 'report_place_dialog.dart';
import '../services/report_service.dart';
import 'add_review_dialog.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    await Future.wait([
      _loadUserDetails(),
      context.read<ReviewProvider>().loadReviews(widget.place.id),
    ]);
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

  void _showAddReviewDialog() {
    final user = context.read<UserProvider>().user;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AddReviewDialog(
        placeId: widget.place.id,
        userId: user.id,
        userFullName: user.fullName,
      ),
    ).then((reviewed) {
      if (reviewed == true) {
        print('Review added, reloading reviews...'); // Debug print
        context.read<ReviewProvider>().loadReviews(widget.place.id);
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

  Widget _buildReportSection() {
    if (!mounted) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 16),
      width: double.infinity,
      child: _canReport
          ? ElevatedButton.icon(
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
            )
          : Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'You have already reported this place',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildReviewSection() {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, _) {
        final reviews = reviewProvider.reviews;
        final loading = reviewProvider.loading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews (${reviews.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final user = context.read<UserProvider>().user;
                    if (user != null) {
                      final hasReviewed = await context
                          .read<ReviewProvider>()
                          .hasUserReviewed(widget.place.id, user.id);

                      if (hasReviewed && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('You have already reviewed this place'),
                          ),
                        );
                        return;
                      }
                      if (mounted) {
                        _showAddReviewDialog();
                      }
                    }
                  },
                  icon: const Icon(Icons.rate_review_outlined, size: 20),
                  label: const Text('Add Review'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Show loading, empty state, or reviews
            if (loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else if (reviews.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.star_border, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No reviews yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first to review this place',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[100],
                              child: Text(
                                review.userFullName[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.userFullName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (i) => Icon(
                                        i < review.rating
                                            ? Icons.star
                                            : Icons.star_border,
                                        size: 16,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              timeago.format(review.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        if (review.review.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            review.review,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
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
                    _buildReviewSection(),
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
                    // Report section
                    _buildReportSection(),
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
