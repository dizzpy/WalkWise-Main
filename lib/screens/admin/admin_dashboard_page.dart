import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walkwise/providers/admin_provider.dart';
import 'package:walkwise/screens/admin/components/admin_places_view.dart';
import 'package:walkwise/screens/admin/components/admin_users_list.dart';
import 'components/admin_stats_grid.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();

    // Load data after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    try {
      await context.read<AdminProvider>().loadDashboardData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Users'),
              Tab(text: 'Places'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Overview Tab
            RefreshIndicator(
              onRefresh: _loadData,
              child: Consumer<AdminProvider>(
                builder: (context, provider, child) {
                  if (provider.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dashboard Overview',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 16),
                        const AdminStatsGrid(),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Users Tab
            const AdminUsersList(),
            // Places Tab
            const AdminPlacesView(),
          ],
        ),
      ),
    );
  }
}
