import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:week5_offline_notes/data/repositories/note_repository.dart';

// ─── Helper: buat in-memory database SQLite untuk pengujian ─────────────────
Future<Database> openInMemoryNotesDb() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE notes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            body TEXT NOT NULL DEFAULT '',
            updated_at TEXT NOT NULL,
            dirty INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    ),
  );
  return db;
}

void main() {
  late Database db;
  late NoteRepository repo;

  setUp(() async {
    db = await openInMemoryNotesDb();
    repo = NoteRepository(openDb: () async => db);
  });

  tearDown(() async {
    await db.close();
  });

  // ─── Skenario 1: fetchNotes pada DB kosong ──────────────────────────────
  group('NoteRepository.fetchNotes', () {
    test('mengembalikan list kosong saat database baru dibuat', () async {
      final notes = await repo.fetchNotes();
      expect(notes, isEmpty);
    });

    test('mengembalikan catatan yang sudah ditambahkan', () async {
      await repo.addNote(title: 'Catatan 1', body: 'Isi 1');
      await repo.addNote(title: 'Catatan 2', body: 'Isi 2');

      final notes = await repo.fetchNotes();
      expect(notes, hasLength(2));
      // Diurutkan updated_at DESC — catatan 2 lebih baru
      expect(notes.first.title, equals('Catatan 2'));
    });
  });

  // ─── Skenario 2: addNote ────────────────────────────────────────────────
  group('NoteRepository.addNote', () {
    test(
      'note yang baru ditambahkan memiliki dirty=true dan id valid',
      () async {
        final note = await repo.addNote(title: 'Baru', body: 'Isi baru');
        expect(note.id, isNotNull);
        expect(note.id, greaterThan(0));
        expect(note.dirty, isTrue);
        expect(note.title, equals('Baru'));
      },
    );

    test('addNote tanpa body menggunakan default string kosong', () async {
      final note = await repo.addNote(title: 'Tanpa Isi');
      expect(note.body, equals(''));
    });
  });

  // ─── Skenario 3: deleteNote ─────────────────────────────────────────────
  group('NoteRepository.deleteNote', () {
    test('note yang dihapus tidak ada lagi di daftar', () async {
      final note = await repo.addNote(title: 'Akan dihapus');
      await repo.deleteNote(note.id!);

      final notes = await repo.fetchNotes();
      expect(notes.any((n) => n.id == note.id), isFalse);
    });
  });

  // ─── Skenario 4: countDirty & markAllSynced ─────────────────────────────
  group('NoteRepository.countDirty & markAllSynced', () {
    test('countDirty menghitung note yang belum tersinkron', () async {
      await repo.addNote(title: 'Note A');
      await repo.addNote(title: 'Note B');

      final count = await repo.countDirty();
      expect(count, equals(2));
    });

    test('markAllSynced mengubah semua dirty=true menjadi false', () async {
      await repo.addNote(title: 'Note X');
      expect(await repo.countDirty(), equals(1));

      await repo.markAllSynced();
      expect(await repo.countDirty(), equals(0));
    });
  });

  // ─── Skenario 5: syncNotes (dengan fake delay) ──────────────────────────
  group('syncNotes', () {
    test(
      'mengembalikan 0 dan tidak melakukan apa-apa jika tidak ada dirty note',
      () async {
        final synced = await syncNotes(repo);
        expect(synced, equals(0));
      },
    );

    test(
      'mengembalikan jumlah note yang disinkronkan dan me-reset dirty flag',
      () async {
        await repo.addNote(title: 'Sync test 1');
        await repo.addNote(title: 'Sync test 2');

        final synced = await syncNotes(repo);
        expect(synced, equals(2));
        expect(await repo.countDirty(), equals(0));
      },
    );
  });
}
