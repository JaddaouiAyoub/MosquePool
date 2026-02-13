import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final userModel = UserModel(
          id: credential.user!.uid,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phone: phone,
        );

        await _firestore.collection('users').doc(userModel.id).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return userModel;
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred during signup.';
    }
    return null;
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return await getUserData(credential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred during login.';
    }
    return null;
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        return UserModel(
          id: uid,
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          email: data['email'] ?? '',
          phone: data['phone'] ?? '',
        );
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password provided is too weak.';
      default:
        return e.message ?? 'An unknown authentication error occurred.';
    }
  }
}
