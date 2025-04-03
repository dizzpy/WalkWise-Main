import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';

class AdminPlacesView extends StatelessWidget {
  const AdminPlacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'All Places'),
              Tab(text: 'Reported'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _AllPlacesList(),
                _ReportedPlacesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllPlacesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider?.places.length,
          itemBuilder: (context, index) {
            final place = provider.places[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.place),
                title: Text(place.name),
                subtitle: Text(place.address),
                trailing: Text(place.tags.join(', ')),
              ),
            );
          },
        );
      },
    );
  }
}

class _ReportedPlacesList extends StatelessWidget {
  Future<bool> _confirmAction(BuildContext context, String action) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('$action Report'),
            content: Text('Are you sure you want to $action this report?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor:
                      action == 'Delete' ? Colors.red : Colors.green,
                ),
                child: Text(action),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _handleReportAction(
    BuildContext context,
    String reportId,
    String action,
  ) async {
    try {
      final confirmed = await _confirmAction(context, action);
      if (!confirmed) return;

      final provider = context.read<AdminProvider>();

      if (action == 'Delete') {
        await provider.deleteReport(reportId);
      } else {
        await provider.resolveReport(reportId);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Report ${action.toLowerCase()}d successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error ${action.toLowerCase()}ing report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.reportedPlaces.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No reported places',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.reportedPlaces.length,
          itemBuilder: (context, index) {
            final report = provider.reportedPlaces[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.red[50],
              child: ListTile(
                leading: const Icon(Icons.report_problem, color: Colors.red),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.placeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        report.reason,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[900],
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(report.details),
                ),
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'resolve',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: Colors.green[700], size: 20),
                          const SizedBox(width: 8),
                          const Text('Mark as resolved'),
                        ],
                      ),
                      onTap: () => Future.delayed(
                        const Duration(seconds: 0),
                        () =>
                            _handleReportAction(context, report.id, 'Resolve'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          const Text('Delete report',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () => Future.delayed(
                        const Duration(seconds: 0),
                        () => _handleReportAction(context, report.id, 'Delete'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
