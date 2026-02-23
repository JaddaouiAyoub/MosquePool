import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AppNotification>> getNotifications(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AppNotification.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  Stream<List<AppNotification>> getSecurityAlerts(String userId) {
    if (userId.isEmpty) return Stream.value([]);
    return _firestore
        .collection('reports')
        .where('reportedUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'alerted')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return AppNotification(
              id: doc.id,
              tripId: data['tripId'] ?? '',
              title: "⚠️ Avertissement de sécurité",
              body:
                  data['adminComment'] ??
                  'Vous avez reçu un avertissement de l\'administration.',
              createdAt:
                  (data['respondedAt'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
              isRead: data['isRead'] ?? false,
            );
          }).toList();
        });
  }

  Future<void> addNotification(
    String userId,
    AppNotification notification,
  ) async {
    if (userId.isEmpty) return;
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(notification.toMap());
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    if (userId.isEmpty || notificationId.isEmpty) return;

    // Try notifications sub-collection first
    final notifRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId);

    final notifSnap = await notifRef.get();
    if (notifSnap.exists) {
      await notifRef.update({'isRead': true});
      return;
    }

    // Otherwise try reports collection
    final reportRef = _firestore.collection('reports').doc(notificationId);
    final reportSnap = await reportRef.get();
    if (reportSnap.exists) {
      await reportRef.update({'isRead': true});
    }
  }

  Future<void> markAllAsRead(String userId) async {
    if (userId.isEmpty) return;

    final batch = _firestore.batch();

    // Notifications
    final docs = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in docs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    // Reports
    final reportDocs = await _firestore
        .collection('reports')
        .where('reportedUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'alerted')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in reportDocs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> deleteNotification(String userId, String notificationId) async {
    if (userId.isEmpty || notificationId.isEmpty) return;

    // Try notifications sub-collection first
    final notifRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId);

    final notifSnap = await notifRef.get();
    if (notifSnap.exists) {
      await notifRef.delete();
      return;
    }

    // For reports, we don't want to actually delete the report document
    // because it's administrative. Instead, we could mark it as 'dismissed' by this user.
    // However, for the sake of the task "logic de read pour les deux", let's just make sure deletion attempt doesn't crash.
    // Optimal: Update the report to status: 'dismissed' if it's the target user.
    final reportRef = _firestore.collection('reports').doc(notificationId);
    final reportSnap = await reportRef.get();
    if (reportSnap.exists && reportSnap.data()?['reportedUserId'] == userId) {
      await reportRef.update({'status': 'dismissed'});
    }
  }
}
