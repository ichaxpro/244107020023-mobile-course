import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:week5_offline_notes/main.dart';
import 'package:week5_offline_notes/providers/notes_provider.dart';
import 'package:week5_offline_notes/data/local/note.dart';

void main() {
  testWidgets('menampilkan status offline dan dirty badge',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesProvider.overrideWith(TestNotesNotifier.new),
          dirtyNotesCountProvider.overrideWith((ref) async => 2),
          forceOfflineProvider.overrideWith(TestForceOfflineNotifier.new),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Catatan Offline'), findsOneWidget);
    expect(find.text('Belum tersinkron: 2'), findsOneWidget);
    expect(find.text('Belanja bulanan'), findsOneWidget);
    expect(find.text('Dirty'), findsOneWidget);
  });
}

class TestNotesNotifier extends NotesNotifier {
  @override
  Future<List<Note>> build() async => [
        Note(
          title: 'Belanja bulanan',
          body: 'Simpan meski offline',
          updatedAt: DateTime(2026),
          dirty: true,
        ),
      ];
}

class TestForceOfflineNotifier extends ForceOfflineNotifier {
  @override
  Future<bool> build() async => true;
}
