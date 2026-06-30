import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final list = provider.notifications;
    final loading = provider.loading;

    return Scaffold(
      backgroundColor: BhauColors.bg1,
      appBar: AppBar(
        backgroundColor: BhauColors.bg2,
        title: const Text(
          'NOTIFICATIONS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        actions: [
          if (list.any((n) => n['isRead'] == false))
            IconButton(
              tooltip: 'Mark all as read',
              icon: Icon(Icons.done_all, color: BhauColors.cyan),
              onPressed: () => provider.markAllAsRead(),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchNotifications(),
        child: loading
            ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(BhauColors.cyan)))
            : list.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(list[index], provider);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            children: [
              Icon(Icons.notifications_off_outlined, size: 48, color: Colors.white24),
              SizedBox(height: 16),
              Text(
                'No notifications yet.',
                style: TextStyle(color: Colors.white60, fontSize: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> n, NotificationProvider provider) {
    final id = n['id'] as int;
    final title = n['title'] as String;
    final body = n['body'] as String;
    final type = n['type'] as String;
    final isRead = n['isRead'] as bool;
    final date = DateTime.parse(n['createdAt']);
    final df = DateFormat('d MMM, h:mm a');

    IconData icon;
    Color iconColor;

    switch (type) {
      case 'MembershipExpiry':
        icon = Icons.warning_amber_rounded;
        iconColor = BhauColors.warn;
        break;
      case 'ClassReminder':
        icon = Icons.event;
        iconColor = BhauColors.cyan;
        break;
      case 'WorkoutReminder':
        icon = Icons.fitness_center;
        iconColor = BhauColors.lime;
        break;
      default:
        icon = Icons.notifications_none;
        iconColor = Colors.white70;
        break;
    }

    return Card(
      color: isRead ? BhauColors.bg2.withOpacity(0.6) : BhauColors.bg2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isRead ? BorderSide.none : BorderSide(color: BhauColors.cyan, width: 0.5),
      ),
      child: ListTile(
        onTap: isRead ? null : () => provider.markAsRead(id),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            color: isRead ? Colors.white70 : Colors.white,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(body, style: const TextStyle(fontSize: 12, color: Colors.white60)),
            const SizedBox(height: 6),
            Text(df.format(date.toLocal()), style: const TextStyle(fontSize: 10, color: Colors.white38)),
          ],
        ),
        trailing: isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: BhauColors.cyan,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}
