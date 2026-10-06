import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/person.dart';
import '../data/person_repository.dart';

final personRepositoryProvider = Provider<PersonRepository>((ref) {
  return PersonRepository(ref.watch(workspaceCollectionProvider('people')));
});

/// Roster de personas (Familia) en tiempo real.
final peopleProvider = StreamProvider<List<Person>>((ref) async* {
  await ref.watch(anonymousSessionProvider.future);
  yield* ref.watch(personRepositoryProvider).watchAll();
});

/// Mapa id → persona, para resolver rápido quién es quién.
final peopleByIdProvider = Provider<Map<String, Person>>((ref) {
  final people = ref.watch(peopleProvider).value ?? const <Person>[];
  return {for (final p in people) p.id: p};
});
