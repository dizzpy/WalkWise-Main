import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkwise/models/user_model.dart';
import '../../constants/app_assets.dart';
import '../../constants/colors.dart';
import '../../components/custom_icon_button.dart';
import '../../components/custom_segmented_control.dart';
import '../../components/place_card.dart';
import '../../providers/user_provider.dart';
import '../../components/skeleton_loading.dart';
import 'edit_profile_bottom_sheet.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move loadUser to didChangeDependencies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUser();
    });
  }

  void _showEditProfileBottomSheet(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileBottomSheet(user: user),
    );
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

  Widget _buildLocationInfo(String location) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_on_outlined,
            size: 16,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            location,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
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
                    if (user != null) _buildLocationInfo(user.location),
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
                          ListView(
                            children: const [
                              PlaceCard(
                                name: 'Central Park',
                                date: '2023-08-15',
                                rating: 4.5,
                              ),
                              PlaceCard(
                                name: 'Times Square',
                                date: '2023-08-14',
                                rating: 4.0,
                              ),
                            ],
                          ),
                          // Last Viewed View
                          ListView(
                            children: const [
                              PlaceCard(
                                name: 'Brooklyn Bridge',
                                date: '2023-08-13',
                                rating: 4.8,
                              ),
                              PlaceCard(
                                name: 'Empire State Building',
                                date: '2023-08-12',
                                rating: 4.2,
                              ),
                            ],
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
