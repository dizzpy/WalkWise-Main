import 'package:flutter/material.dart';
import '../../constants/app_assets.dart';
import '../../constants/colors.dart';
import '../../components/custom_icon_button.dart';
import '../../components/custom_segmented_control.dart';
import '../../components/place_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

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
                  // Add edit profile logic here
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(44),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://avatars.githubusercontent.com/u/28524634?v=4',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Anuja Rathnayaka',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 24),
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
  }
}
