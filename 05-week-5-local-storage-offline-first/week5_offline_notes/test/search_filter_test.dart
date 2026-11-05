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

    test('query kosong kembalikan seluruh daftar catatan', () {
      final result = useCase.execute(sampleNotes, '');
      expect(result.length, equals(3));
    });

    test('filter abaikan huruf besar/kecil (case-insensitive)', () {
      // Query huruf kecil 'belanja' harus mencocokkan 'Belanja Bulanan' dan 'BELANJA Elektronik'
      final result = useCase.execute(sampleNotes, 'belanja');
      expect(result, hasLength(2));
      expect(result.map((n) => n.id), containsAll([1, 3]));
    });

    test('query tak cocok kembalikan kosong (memicu empty state)', () {
      final result = useCase.execute(sampleNotes, 'zzz-tak-ada');
      expect(result, isEmpty);
    });

    test('query dengan spasi di awal dan akhir otomatis ditrim', () {
      final result = useCase.execute(sampleNotes, '   kuliah   ');
      expect(result, hasLength(1));
      expect(result.first.title, contains('Kuliah'));
    });

    test('daftar catatan kosong tetap aman dan kembalikan kosong', () {
      final result = useCase.execute([], 'apapun');
      expect(result, isEmpty);
    });
  });
}
