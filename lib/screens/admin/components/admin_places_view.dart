import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/admin_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

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
          itemCount: provider.places.length,
          itemBuilder: (context, index) {
            final place = provider.places[index];
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.place, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                place.address,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (place.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: place.tags
                            .map((tag) => Chip(
                                  label: Text(tag),
                                  backgroundColor: Colors.grey[100],
                                  labelStyle: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 12,
                                  ),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ))
                            .toList(),
                      ),
                    ],
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
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.shade200),
              ),
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.report_problem,
                              color: Colors.red[700], size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.placeName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
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
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  report.reason,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red[900],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton(
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
                                () => _handleReportAction(
                                    context, report.id, 'Resolve'),
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
                                () => _handleReportAction(
                                    context, report.id, 'Delete'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (report.details.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Details:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red[900],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.details,
                        style: TextStyle(
                          color: Colors.red[900],
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.red[800]),
                        const SizedBox(width: 4),
                        Text(
                          'Reported ${timeago.format(report.reportedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[800],
                          ),
                        ),
                      ],
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
