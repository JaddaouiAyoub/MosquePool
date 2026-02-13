import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip.dart';

class TripRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Trip>> getActiveTrips() {
    return _firestore
        .collection('trips')
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Trip.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> createTrip(Trip trip) async {
    // When creating, we use the timestamp from the trip object 
    // but we could also use FieldValue.serverTimestamp() if we wanted.
    // However, since Trip.fromMap expects a string/DateTime, 
    // using the trip's createdAt is fine.
    await _firestore.collection('trips').add(trip.toMap());
  }

  Future<void> updateTrip(Trip trip) async {
    if (trip.id.isEmpty) return;
    await _firestore
        .collection('trips')
        .doc(trip.id)
        .set(trip.toMap(), SetOptions(merge: true));
  }

  Future<void> joinTrip(String tripId, Map<String, dynamic> userData) async {
    if (tripId.isEmpty) return;
    final userId = userData['id'];
    await _firestore.collection('trips').doc(tripId).update({
      'interestedUsers': FieldValue.arrayUnion([userData]),
      'seatsAvailable': FieldValue.increment(-1),
      'interactionCounts.$userId': FieldValue.increment(1),
    });
  }

  Future<void> leaveTrip(String tripId, Map<String, dynamic> userData) async {
    if (tripId.isEmpty) return;
    final userId = userData['id'];
    await _firestore.collection('trips').doc(tripId).update({
      'interestedUsers': FieldValue.arrayRemove([userData]),
      'seatsAvailable': FieldValue.increment(1),
      'interactionCounts.$userId': FieldValue.increment(1),
    });
  }
}
