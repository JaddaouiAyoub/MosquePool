import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mosque.dart';

class MosqueRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Mosque>> getMosques() {
    return _firestore.collection('mosques').orderBy('name').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Mosque.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }
}
