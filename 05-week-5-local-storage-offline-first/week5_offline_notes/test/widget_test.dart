import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:week5_offline_notes/main.dart';
import 'package:week5_offline_notes/providers/notes_provider.dart';
import 'package:week5_offline_notes/data/local/note.dart';

void main() {
  testWidgets('menampilkan status offline, dirty badge, dan search input',
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
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Belanja bulanan'), findsOneWidget);
    expect(find.text('Dirty'), findsOneWidget);
  });

  testWidgets('filter catatan melalui search field dan tampilkan empty state saat tak cocok',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesProvider.overrideWith(TestNotesNotifier.new),
          dirtyNotesCountProvider.overrideWith((ref) async => 0),
          forceOfflineProvider.overrideWith(TestForceOfflineNotifier.new),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belanja bulanan'), findsOneWidget);

    // Cari dengan query yang cocok
    await tester.enterText(find.byType(TextField), 'belanja');
    await tester.pumpAndSettle();

    expect(find.text('Belanja bulanan'), findsOneWidget);
    expect(find.text('Hasil pencarian (1)'), findsOneWidget);

    // Cari dengan query yang tidak ada
    await tester.enterText(find.byType(TextField), 'zzz-tak-ada');
    await tester.pumpAndSettle();

    expect(find.text('Belanja bulanan'), findsNothing);
    expect(find.text('Tidak ada catatan dengan judul "zzz-tak-ada"'), findsOneWidget);
    expect(find.byIcon(Icons.search_off), findsOneWidget);
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
