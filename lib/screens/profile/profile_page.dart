import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkwise/models/place_model.dart';
import 'package:walkwise/models/user_model.dart';
import 'package:walkwise/screens/auth/location_selection_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_assets.dart';
import '../../constants/colors.dart';
import '../../components/custom_icon_button.dart';
import '../../components/custom_segmented_control.dart';
import '../../providers/user_provider.dart';
import '../../providers/place_provider.dart';
import '../../components/skeleton_loading.dart';
import '../../components/suggested_place_card.dart';
import '../../components/place_details_sheet.dart';
import 'edit_profile_bottom_sheet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<UserProvider>().loadUser();
      final user = context.read<UserProvider>().user;
      if (user != null) {
        await Future.wait([
          context.read<PlaceProvider>().loadPlaces(),
          context.read<PlaceProvider>().loadLastViewedPlaces(user.id),
        ]);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _showEditProfileBottomSheet(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileBottomSheet(user: user),
    );
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

  String _formatLocation(String location) {
    return location.split(',').first.trim();
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 24),
        const SkeletonLoading(
          width: 130,
          height: 130,
          borderRadius: 44,
        ),
        const SizedBox(height: 16),
        const SkeletonLoading(width: 150, height: 24),
        const SizedBox(height: 24),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: const SkeletonLoading(
            width: double.infinity,
            height: 50,
            borderRadius: 12,
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: const SkeletonLoading(
                  width: double.infinity,
                  height: 80,
                  borderRadius: 12,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(UserModel? user) {
    if (user == null) return const SizedBox.shrink();

    if (user.location.isEmpty || user.location == 'New York, USA') {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const LocationSelectionPage()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppAssets.mapIcon,
                    width: 20,
                    height: 20,
                    color: AppColors.primary.withOpacity(0.8),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Set your location',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const LocationSelectionPage()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppAssets.locationPinIcon,
                  width: 20,
                  height: 20,
                  color: AppColors.primary.withOpacity(0.8),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _formatLocation(user.location),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlacesList(List<PlaceModel> places, String emptyMessage) {
    if (places.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.place_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
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
          addedByName: 'You',
          onTap: () => _showPlaceDetails(place),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        final loading = userProvider.loading;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 16),
            child: Container(
              padding: EdgeInsets.only(
                top: topPadding + 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              color: AppColors.background,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomIconButton(
                    icon: AppAssets.backIcon,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  CustomIconButton(
                    icon: AppAssets.editIcon,
                    onPressed: () {
                      if (user != null) {
                        _showEditProfileBottomSheet(user);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          body: loading
              ? _buildLoadingState()
              : Column(
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(44),
                          image: DecorationImage(
                            image: NetworkImage(
                              user?.profileImgLink.isNotEmpty == true
                                  ? user!.profileImgLink
                                  : 'https://avatars.githubusercontent.com/u/28524634?v=4',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.fullName ?? 'User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildLocationInfo(user),
                    const SizedBox(height: 24), // Adjusted spacing
                    CustomSegmentedControl(
                      selectedIndex: _selectedIndex,
                      segments: const ['Added Places', 'Last Viewed'],
                      onSegmentTapped: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: [
                          // Added Places View
                          Consumer2<UserProvider, PlaceProvider>(
                            builder: (context, userProvider, placeProvider, _) {
                              final user = userProvider.user;
                              final allPlaces = placeProvider.places;

                              // Filter places where addedBy matches current user's ID
                              final userAddedPlaces = allPlaces
                                  .where((place) => place.addedBy == user?.id)
                                  .toList();

                              return _buildPlacesList(
                                userAddedPlaces,
                                'No places added yet',
                              );
                            },
                          ),
                          // Last Viewed View
                          Consumer<PlaceProvider>(
                            builder: (context, provider, _) => _buildPlacesList(
                              provider.lastViewedPlaces,
                              'No places viewed yet',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
