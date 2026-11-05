import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/note_repository.dart';
import '../data/local/note.dart';
import '../data/prefs.dart';
import '../domain/search_notes_use_case.dart';

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepository(),
);

final forceOfflineProvider =
    AsyncNotifierProvider<ForceOfflineNotifier, bool>(
  ForceOfflineNotifier.new,
);

class ForceOfflineNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() {
    return ref.read(prefsRepositoryProvider).getForceOffline();
  }

  Future<void> setForceOffline(bool value) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(prefsRepositoryProvider).setForceOffline(value);
      return value;
    });
  }

  Future<void> toggle() async {
    await setForceOffline(!(state.value ?? false));
  }
}

final prefsRepositoryProvider = Provider<PrefsRepository>(
  (ref) => PrefsRepository(),
);

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

final dirtyNotesCountProvider = FutureProvider<int>((ref) {
  return ref.read(noteRepositoryProvider).countDirty();
});

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() {
    return ref.read(noteRepositoryProvider).fetchNotes();
  }

  Future<void> reload() async {
    state = await AsyncValue.guard(
      () => ref.read(noteRepositoryProvider).fetchNotes(),
    );
    ref.invalidate(dirtyNotesCountProvider);
  }

  Future<void> addNote({required String title, String body = ''}) async {
    await ref.read(noteRepositoryProvider).addNote(title: title, body: body);
    await reload();
  }

  Future<int> sync() async {
    if (await ref.read(forceOfflineProvider.future)) {
      return 0;
    }

    final synced = await syncNotes(ref.read(noteRepositoryProvider));
    await reload();
    return synced;
  }
}

/// Provider instance use case pencarian murni di layer Domain
final searchNotesUseCaseProvider = Provider<SearchNotesUseCase>((ref) {
  return const SearchNotesUseCase();
});

/// Notifier untuk mengelola teks query pencarian
final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// Provider reaktif yang mengembalikan daftar catatan yang telah difilter sesuai query
final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final notesAsync = ref.watch(notesProvider);
  final query = ref.watch(searchQueryProvider);
  final useCase = ref.watch(searchNotesUseCaseProvider);

  return notesAsync.whenData((notes) => useCase.execute(notes, query));
});
