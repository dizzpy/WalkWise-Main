import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../profile/profile_page.dart';
import '../../constants/colors.dart';
import '../../components/custom_button.dart';
import '../../providers/user_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Move loadUser to didChangeDependencies
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadUser();
    });
  }

  Future<void> _handleLogout() async {
    try {
      await context.read<UserProvider>().logout();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to logout. Please try again.')),
        );
      }
    }
  }

  Future<void> _showLogoutConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _handleLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final user = userProvider.user;
        final loading = userProvider.loading;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.primary,
            elevation: 0,
          ),
          body: Column(
            children: [
              // Profile Card
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfilePage()),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.outline, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.background,
                                backgroundImage: NetworkImage(
                                  user?.profileImgLink.isNotEmpty == true
                                      ? user!.profileImgLink
                                      : 'https://avatars.githubusercontent.com/u/28524634?v=4',
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.fullName ?? 'Loading...',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.email ?? 'Loading...',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),

              // Settings Items
              Expanded(
                child: ListView(
                  children: [
                    _buildSettingsItem(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Icons.lock,
                      title: 'Privacy',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Icons.help,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    _buildSettingsItem(
                      icon: Icons.info,
                      title: 'About',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // Updated Logout Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: CustomButton(
                  onPressed: _showLogoutConfirmation,
                  text: 'Logout',
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
