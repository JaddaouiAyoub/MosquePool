import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final userProvider = NotifierProvider<UserNotifier, AsyncValue<UserModel?>>(
  UserNotifier.new,
);

class UserNotifier extends Notifier<AsyncValue<UserModel?>> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AsyncValue<UserModel?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email: email, password: password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AsyncValue.data(null);
  }

  void loadUser(UserModel user) {
    state = AsyncValue.data(user);
  }
}
