import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mosque.dart';
import '../data/mosque_repository.dart';

final mosqueRepositoryProvider = Provider((ref) => MosqueRepository());

final mosquesProvider = StreamProvider<List<Mosque>>((ref) {
  final repository = ref.watch(mosqueRepositoryProvider);
  return repository.getMosques();
});
