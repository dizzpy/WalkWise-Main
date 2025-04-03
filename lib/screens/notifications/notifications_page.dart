import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../components/skeleton_loading.dart';
import '../../providers/user_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/notification_service.dart';
import '../../models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final user = context.read<UserProvider>().user;
      if (user != null) {
        final notifications =
            await _notificationService.getNotifications(user.id);
        setState(() => _notifications = notifications);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    try {
      await _notificationService.markAsRead(notification.id);
      context.read<NotificationProvider>().decrementUnreadCount();
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    final user = context.read<UserProvider>().user;
    if (user != null) {
      await _notificationService.markAllAsRead(user.id);
      context.read<NotificationProvider>().resetUnreadCount();
      await _loadNotifications();
    }
  }

  Future<bool> _confirmDelete() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Notification'),
            content: const Text(
                'Are you sure you want to delete this notification?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _handleDismissed(
    DismissDirection direction,
    NotificationModel notification,
  ) async {
    final notificationIndex = _notifications.indexOf(notification);
    final notificationCopy = notification;

    setState(() {
      _notifications.remove(notification);
    });

    try {
      if (direction == DismissDirection.endToStart) {
        // Show confirmation dialog before deleting
        final shouldDelete = await _confirmDelete();
        if (!shouldDelete) {
          // Restore the notification if delete is cancelled
          setState(() {
            _notifications.insert(notificationIndex, notificationCopy);
          });
          return;
        }

        await _notificationService.deleteNotification(notification.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notification deleted')),
          );
        }
      } else if (direction == DismissDirection.startToEnd) {
        await _notificationService.markAsRead(notification.id);
        context.read<NotificationProvider>().decrementUnreadCount();
        final updatedNotification = NotificationModel(
          id: notification.id,
          title: notification.title,
          message: notification.message,
          createdAt: notification.createdAt,
          isRead: true,
          placeId: notification.placeId,
          userId: notification.userId,
        );
        setState(() {
          _notifications.insert(notificationIndex, updatedNotification);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Marked as read')),
          );
        }
      }
    } catch (e) {
      // Restore the notification if there's an error
      setState(() {
        _notifications.insert(notificationIndex, notificationCopy);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error updating notification')),
        );
      }
    }
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String time,
    bool isUnread = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isUnread ? Colors.blue.shade50.withOpacity(0.3) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: Colors.blue.shade100.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Stack(
        children: [
          if (isUnread)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.shade400,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
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

  Widget _buildDismissibleNotification(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.check_circle, color: Colors.green.shade700),
        ),
      ),
      secondaryBackground: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.delete, color: Colors.red.shade700),
        ),
      ),
      onDismissed: (direction) => _handleDismissed(direction, notification),
      child: _buildNotificationItem(
        title: notification.title,
        message: notification.message,
        time: timeago.format(notification.createdAt),
        isUnread: !notification.isRead,
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SkeletonLoading(
              width: 200,
              height: 24,
              borderRadius: 4,
            ),
            SizedBox(height: 8),
            SkeletonLoading(
              width: double.infinity,
              height: 16,
              borderRadius: 4,
            ),
            SizedBox(height: 8),
            SkeletonLoading(
              width: 100,
              height: 12,
              borderRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeInstructions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.swipe_right, color: Colors.green[400], size: 20),
              const SizedBox(width: 4),
              Text(
                'Swipe right to mark as read',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Swipe left to delete',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.swipe_left, color: Colors.red[400], size: 20),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _markAllAsRead,
            icon: Icon(Icons.done_all, size: 20, color: Colors.grey[600]),
            label: Text(
              'Mark all as read',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _notifications.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildSwipeInstructions(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadNotifications,
                        child: ListView.builder(
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            return _buildDismissibleNotification(
                                _notifications[index]);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
