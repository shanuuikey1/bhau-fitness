import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/token_storage.dart';

class NotificationProvider with ChangeNotifier {
  final _api = ApiService();
  final _tokenStorage = TokenStorage();
  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _loading = false;
  Timer? _timer;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get loading => _loading;

  NotificationProvider() {
    // Start periodic polling for unread notifications count
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => fetchUnreadCount());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchNotifications() async {
    _loading = true;
    notifyListeners();
    try {
      final res = await _api.getNotifications();
      _notifications = res;
      // Also update unread count based on fetched list
      _unreadCount = _notifications.where((n) => n['isRead'] == false).length;
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      // Don't hit the API (and log 401s) while nobody is logged in.
      final token = await _tokenStorage.readToken();
      if (token == null || token.isEmpty) return;

      final count = await _api.getUnreadCount();
      if (_unreadCount != count) {
        _unreadCount = count;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }

  Future<void> markAsRead(int id) async {
    // Optimistic update
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1 && _notifications[index]['isRead'] == false) {
      _notifications[index]['isRead'] = true;
      if (_unreadCount > 0) _unreadCount--;
      notifyListeners();
    }

    try {
      await _api.markNotificationRead(id);
    } catch (e) {
      debugPrint('Error marking notification read: $e');
      // Revert on error (optional, for simplicity we keep optimistic)
    }
  }

  Future<void> markAllAsRead() async {
    // Optimistic update
    for (var n in _notifications) {
      n['isRead'] = true;
    }
    _unreadCount = 0;
    notifyListeners();

    try {
      await _api.markAllNotificationsRead();
    } catch (e) {
      debugPrint('Error marking all notifications read: $e');
    }
  }
}
