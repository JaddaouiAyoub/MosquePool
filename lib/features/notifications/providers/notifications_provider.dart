import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../data/notification_repository.dart';
import '../../trips/providers/trips_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) => NotificationRepository());

class NotificationsNotifier extends Notifier<List<AppNotification>> {
  NotificationRepository get _repository => ref.read(notificationRepositoryProvider);
  StreamSubscription? _subscription;

  @override
  List<AppNotification> build() {
    final user = ref.watch(profileProvider);
    
    ref.onDispose(() {
      _subscription?.cancel();
    });

    if (user.id.isNotEmpty) {
      _listenToNotifications(user.id);
    }
    return [];
  }

  void _listenToNotifications(String userId) {
    _subscription?.cancel();
    _subscription = _repository.getNotifications(userId).listen((notifications) {
      state = notifications;
    });
  }

  Future<void> addNotification(String targetUserId, AppNotification notification) async {
    await _repository.addNotification(targetUserId, notification);
  }

  Future<void> markAsRead(String id) async {
    final user = ref.read(profileProvider);
    await _repository.markAsRead(user.id, id);
  }

  Future<void> markAllAsRead() async {
    final user = ref.read(profileProvider);
    await _repository.markAllAsRead(user.id);
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );
