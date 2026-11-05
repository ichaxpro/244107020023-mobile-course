import '../data/local/note.dart';

/// Use case murni di layer Domain untuk menyaring catatan berdasarkan judul.
/// Bebas dari dependensi UI (Flutter) dan data layer (SQLite / Dio).
class SearchNotesUseCase {
  const SearchNotesUseCase();

  /// Menyaring daftar [notes] berdasarkan [query] pencarian pada field `title`.
  /// Pencarian bersifat case-insensitive dan mengabaikan spasi berlebih di awal/akhir.
  /// Jika [query] kosong, mengembalikan seluruh daftar [notes].
  List<Note> execute(List<Note> notes, String query) {
    final trimmedQuery = query.trim().toLowerCase();
    if (trimmedQuery.isEmpty) {
      return notes;
    }

    return notes.where((note) {
      return note.title.toLowerCase().contains(trimmedQuery);
    }).toList();
  }
}
