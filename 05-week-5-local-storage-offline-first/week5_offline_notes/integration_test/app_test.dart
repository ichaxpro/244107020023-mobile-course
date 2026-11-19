import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';

import 'package:week5_offline_notes/main.dart';
import 'package:week5_offline_notes/providers/notes_provider.dart';
import 'package:week5_offline_notes/data/local/note.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // ─── Alur utama: membuka app → melihat tampilan awal ───────────────────────
  testWidgets('app terbuka dan menampilkan halaman Catatan Offline',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesProvider.overrideWith(IntegrationTestNotesNotifier.new),
          dirtyNotesCountProvider.overrideWith((ref) async => 1),
          forceOfflineProvider
              .overrideWith(IntegrationTestForceOfflineNotifier.new),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verifikasi judul halaman
    expect(find.text('Catatan Offline'), findsOneWidget);
    // Verifikasi badge dirty count
    expect(find.text('Belum tersinkron: 1'), findsOneWidget);
    // Verifikasi note dari stub terlihat
    expect(find.text('Integrasi Note'), findsOneWidget);
  });

  // ─── Alur pencarian: masukkan query → filter berjalan ──────────────────────
  testWidgets('pengguna mengetik query dan daftar catatan terfilter',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notesProvider.overrideWith(IntegrationTestNotesNotifier.new),
          dirtyNotesCountProvider.overrideWith((ref) async => 0),
          forceOfflineProvider
              .overrideWith(IntegrationTestForceOfflineNotifier.new),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Note awal terlihat
    expect(find.text('Integrasi Note'), findsOneWidget);

    // Ketik query yang cocok
    await tester.enterText(find.byType(TextField), 'Integrasi');
    await tester.pumpAndSettle();
    expect(find.text('Integrasi Note'), findsOneWidget);
    expect(find.text('Hasil pencarian (1)'), findsOneWidget);

    // Ketik query yang tidak cocok → empty state
    await tester.enterText(find.byType(TextField), 'xyz-tidak-ada');
    await tester.pumpAndSettle();
    expect(find.text('Integrasi Note'), findsNothing);
    expect(
      find.text('Tidak ada catatan dengan judul "xyz-tidak-ada"'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.search_off), findsOneWidget);
  });
}

// ─── Stub providers untuk integration test ────────────────────────────────────
class IntegrationTestNotesNotifier extends NotesNotifier {
  @override
  Future<List<Note>> build() async => [
        Note(
          id: 99,
          title: 'Integrasi Note',
          body: 'Catatan untuk integration test',
          updatedAt: DateTime(2026, 11, 19),
          dirty: true,
        ),
      ];
}

class IntegrationTestForceOfflineNotifier extends ForceOfflineNotifier {
  @override
  Future<bool> build() async => false;
}
