import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/domain/search_notes_use_case.dart';

void main() {
  group('SearchNotesUseCase', () {
    const useCase = SearchNotesUseCase();

    final sampleNotes = [
      Note(
        id: 1,
        title: 'Belanja Bulanan',
        body: 'Beras, minyak, gula',
        updatedAt: DateTime(2026, 10, 1),
      ),
      Note(
        id: 2,
        title: 'Tugas Kuliah Pemrograman Mobile',
        body: 'Kerjakan codelab minggu 9',
        updatedAt: DateTime(2026, 10, 2),
      ),
      Note(
        id: 3,
        title: 'Daftar BELANJA Elektronik',
        body: 'Kabel USB-C dan mouse',
        updatedAt: DateTime(2026, 10, 3),
      ),
    ];

    // ─── Skenario 1: query kosong ────────────────────────────────────────────
    test('query kosong kembalikan seluruh daftar catatan', () {
      final result = useCase.execute(sampleNotes, '');
      expect(result.length, equals(3));
    });

    // ─── Skenario 2: case-insensitive ────────────────────────────────────────
    test('filter abaikan huruf besar/kecil (case-insensitive)', () {
      // Query huruf kecil 'belanja' harus mencocokkan 'Belanja Bulanan' dan 'BELANJA Elektronik'
      final result = useCase.execute(sampleNotes, 'belanja');
      expect(result, hasLength(2));
      expect(result.map((n) => n.id), containsAll([1, 3]));
    });

    // ─── Skenario 3: query tidak cocok → empty state ─────────────────────────
    test('query tak cocok kembalikan kosong (memicu empty state)', () {
      final result = useCase.execute(sampleNotes, 'zzz-tak-ada');
      expect(result, isEmpty);
    });

    // ─── Skenario 4 (edge case): spasi di awal/akhir otomatis ditrim ─────────
    test('query dengan spasi di awal dan akhir otomatis ditrim', () {
      final result = useCase.execute(sampleNotes, '   kuliah   ');
      expect(result, hasLength(1));
      expect(result.first.title, contains('Kuliah'));
    });

    // ─── Skenario 5 (edge case): daftar kosong tetap aman ───────────────────
    test('daftar catatan kosong tetap aman dan kembalikan kosong', () {
      final result = useCase.execute([], 'apapun');
      expect(result, isEmpty);
    });

    // ─── Skenario 6 (edge case): query hanya spasi dianggap kosong ──────────
    test('query yang hanya berisi spasi kembalikan seluruh daftar', () {
      final result = useCase.execute(sampleNotes, '   ');
      expect(result.length, equals(3));
    });

    // ─── Skenario 7: pencarian sebagian kata (substring match) ───────────────
    test('pencarian sebagian kata mencocokkan judul yang relevan', () {
      final result = useCase.execute(sampleNotes, 'mob');
      expect(result, hasLength(1));
      expect(result.first.id, equals(2));
    });
  });

  // ─── Unit test Note model ───────────────────────────────────────────────────
  group('Note model', () {
    test('toMap menghasilkan map dengan semua field yang benar', () {
      final note = Note(
        id: 42,
        title: 'Test',
        body: 'Isi catatan',
        updatedAt: DateTime(2026, 11, 1, 10, 0, 0),
        dirty: true,
      );
      final map = note.toMap();

      expect(map['id'], equals(42));
      expect(map['title'], equals('Test'));
      expect(map['body'], equals('Isi catatan'));
      expect(map['dirty'], equals(1));
    });

    test('fromMap merekonstruksi Note dengan benar', () {
      final map = {
        'id': 7,
        'title': 'Judul',
        'body': 'Isi',
        'updated_at': '2026-11-01T00:00:00.000',
        'dirty': 0,
      };
      final note = Note.fromMap(map);

      expect(note.id, equals(7));
      expect(note.title, equals('Judul'));
      expect(note.dirty, isFalse);
    });

    test('fromMap dengan updated_at tidak valid menggunakan epoch', () {
      final map = {
        'id': null,
        'title': '',
        'body': '',
        'updated_at': 'INVALID_DATE',
        'dirty': 0,
      };
      final note = Note.fromMap(map);
      expect(note.updatedAt, equals(DateTime.fromMillisecondsSinceEpoch(0)));
    });

    test('Note dengan dirty=true memiliki flag dirty benar', () {
      final note = Note(
        title: 'Dirty note',
        updatedAt: DateTime(2026),
        dirty: true,
      );
      expect(note.dirty, isTrue);
      expect(note.toMap()['dirty'], equals(1));
    });
  });
}
