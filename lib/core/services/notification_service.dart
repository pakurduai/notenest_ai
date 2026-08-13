import 'package:flutter/material.dart';
import 'package:notenest_ai/core/services/audio_haptic_service.dart';

/// Notification Model for NoteNest
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  bool isRead;
  final String category;
  final IconData icon;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.category = 'system',
    this.icon = Icons.notifications_active_rounded,
  });

  String get timeFormatted {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

/// Central Notification Service for NoteNest AI
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _seedInitialNotifications();
  }

  final List<AppNotification> _notifications = [];
  final List<VoidCallback> _listeners = [];

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addListener(VoidCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (final listener in List.from(_listeners)) {
      try {
        listener();
      } catch (_) {}
    }
  }

  void _seedInitialNotifications() {
    if (_notifications.isNotEmpty) return;
    final now = DateTime.now();
    _notifications.addAll([
      AppNotification(
        id: '1',
        title: 'Welcome to NoteNest AI 🔔',
        body: 'Smart notes, offline storage, and instant AI voice assistant ready to use.',
        timestamp: now.subtract(const Duration(minutes: 2)),
        isRead: false,
        category: 'system',
        icon: Icons.auto_awesome_rounded,
      ),
      AppNotification(
        id: '2',
        title: 'AI Note Assistant Active ✨',
        body: 'Tap the mic button 🎤 or prompt bar to chat with live Gemini AI.',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: false,
        category: 'ai',
        icon: Icons.psychology_rounded,
      ),
      AppNotification(
        id: '3',
        title: 'Local Web Server Connected 🚀',
        body: 'Running smoothly on http://localhost:8080 with 0 latency.',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
        category: 'system',
        icon: Icons.cell_tower_rounded,
      ),
    ]);
  }

  /// Add a new notification and play the Bell Sound chime
  void addNotification({
    required String title,
    required String body,
    String category = 'system',
    IconData icon = Icons.notifications_active_rounded,
    bool playSound = true,
  }) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      isRead: false,
      category: category,
      icon: icon,
    );

    _notifications.insert(0, notification);
    if (playSound) {
      AudioHapticService.playNotificationBellSound();
    }
    _notifyListeners();
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
    _notifyListeners();
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    _notifyListeners();
  }

  /// Test Bell Notification sound chime
  void triggerTestNotification() {
    addNotification(
      title: 'Bell Sound Test 🔔 🔊',
      body: 'Notification bell chime sound played successfully!',
      category: 'test',
      icon: Icons.notifications_active_rounded,
      playSound: true,
    );
  }
}
