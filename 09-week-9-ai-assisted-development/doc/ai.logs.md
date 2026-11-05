# AI Log: Dokumentasi AI-Assisted Development & Vibe Coding
**Mata Kuliah:** Pemrograman Mobile (Codelab #09)  
**Topik:** AI-Assisted Development & Vibe Coding  
**Fitur yang Ditambahkan:** Pencarian Judul Catatan (*Search by Title*) & Status Kosong (*Empty State*)  
**Basis Proyek:** `week5_offline_notes` (Clean Architecture + Riverpod + SQLite)  

---

## 1. Praktikum 1: Prompt dan Context Engineering

### 1.1. Formula 5 Slot
Untuk memastikan instruksi terarah dan tidak menghasilkan kode acak (*vibe coding* tanpa kontrol), prompt disusun menggunakan formula 5 slot:

| Slot | Isi Prompt |
| :--- | :--- |
| **1. Peran (*Role*)** | Senior Flutter & Mobile Software Engineer dengan spesialisasi Clean Architecture. |
| **2. Konteks (*Context*)** | Aplikasi Flutter berbasis Riverpod (`AsyncNotifierProvider`) dan SQLite lokal (`sqflite`). Struktur arsitektur `presentation` -> `domain` <- `data`. Model: `Note(id, title, body, updatedAt, dirty)`. |
| **3. Tugas (*Task*)** | Tambahkan fitur pencarian judul catatan (*search by title*) dengan status kosong (*empty state* jika hasil tidak ditemukan) dan debounce/reactive update. |
| **4. Batasan (*Constraints*)** | - Pisahkan logika filter ke layer domain (*pure Dart use case*, tanpa dependensi `flutter/material.dart`, `sqflite`, atau `dio`).<br>- Jangan panggil database langsung dari widget.<br>- Panjang fungsi/method maksimal 40 baris.<br>- Pencarian harus *case-insensitive* dan mengabaikan spasi berlebih (*trim*). |
| **5. Output (*Deliverables*)** | Kode `SearchNotesUseCase`, pembaruan provider Riverpod, integrasi `TextField` pencarian & Empty State di `main.dart`, serta 3 test case pengujian. |

### 1.2. Perbandingan Prompt Buruk vs Baik
* **Prompt Buruk:**
  > *"Buatkan search notes yang keren di Flutter pake AI secepatnya."*  
  > *Masalah:* Tidak ada batasan arsitektur, rawan menghasilkan kode monolitik yang memanggil SQLite langsung di dalam `build()` widget, tidak case-insensitive, dan sulit diuji.
* **Prompt Baik (yang Digunakan):**
  > *"Sebagai senior Flutter engineer, buatkan use case pencarian judul catatan untuk proyek Riverpod + SQLite ini. Pisahkan logika ke `domain/search_notes_use_case.dart` murni tanpa import Flutter/sqflite. Filter harus case-insensitive dan menangani query kosong/spasi. Sertakan empty state jika query tidak cocok, serta unit test lengkap."*

### 1.3. Prinsip Keamanan & Privasi Konteks
- **Data yang Disertakan:** Kontrak model `Note`, daftar dependency dari `pubspec.yaml`, dan snippet provider Riverpod.
- **Data yang Tidak Disertakan / Dihapus:** API key, token otentikasi/JWT, password database, dan file konfigurasi privat lainnya.

---

## 2. Praktikum 2: Generate dan Verifikasi Fitur Search

### 2.1. Output Awal AI (Sebelum Refactor & Verifikasi)
Berikut adalah kode mentah yang awalnya diusulkan oleh AI:

```dart
// USULAN AWAL AI (Mengandung bug & pelanggaran arsitektur)
import 'package:flutter/material.dart'; // Pelanggaran: Domain mengimpor UI library
import '../data/local/note.dart';
import '../data/repositories/note_repository.dart'; // Pelanggaran: Hubungan tidak perlu

class NoteSearchHelper {
  // Bug 1: Filter case-sensitive (hanya cocok huruf besar/kecil yang sama persis)
  // Bug 2: Tidak melakukan trim() pada query
  static List<Note> doSearch(List<Note> list, String query) {
    if (query == "") return list;
    return list.where((n) => n.title.contains(query)).toList();
  }

  // Halusinasi/Saran Buruk: Memanggil DB query langsung untuk search
  static Future<List<Note>> queryDatabaseDirect(NoteRepository repo, String q) async {
    // Membuka koneksi dan query SQL LIKE di helper UI
    return repo.fetchNotes(); 
  }
}
```

### 2.2. Verifikasi 6 Langkah

| Langkah | Item Pengecekan | Status | Temuan / Catatan Verifikasi |
| :---: | :--- | :---: | :--- |
| **1** | Baca baris per baris | **Selesai** | Ditemukan method `queryDatabaseDirect` yang tidak sesuai peran dan filter `.contains(query)` tanpa normalisasi huruf kecil. |
| **2** | Cek import layer domain | **Gagal $\rightarrow$ Diperbaiki** | Terdeteksi import `package:flutter/material.dart` pada helper logika. Dihapus agar layer domain murni Dart. |
| **3** | Cek API nyata | **Selesai** | Method `String.contains()` dan `List.where()` valid di Dart SDK 3.x. |
| **4** | Jalankan `flutter analyze` | **Selesai** | Diperbaiki hingga nol warning dan nol error linter. |
| **5** | Tulis Unit Test Sukses & Gagal | **Selesai** | Dibuat `test/search_filter_test.dart` (5 skenario uji). |
| **6** | Uji Manual 3 Kondisi Query | **Selesai** | - Query kosong: Seluruh catatan tampil.<br>- Query cocok ('belanja'): Menampilkan catatan belanja terlepas dari kapitalisasi.<br>- Query tak cocok ('zzz-tak-ada'): Menampilkan widget `Icon(Icons.search_off)` & pesan empty state. |

### 2.3. Bukti Wajib: Halusinasi / Bug AI yang Ditemukan
* **Deskripsi Bug:**  
  AI menggunakan `n.title.contains(query)` secara mentah tanpa `toLowerCase()`.
* **Dampak:**  
  Pencarian kata `"belanja"` menghasilkan 0 item jika judul catatan ditulis `"Belanja Bulanan"` (karena huruf 'B' kapital tidak sama dengan 'b' kecil).
* **Bukti Test Merah (Sebelum Bug Diperbaiki):**
  ```dart
  test('filter abaikan huruf besar/kecil', () {
    final list = [Note(title: 'Belanja Bulanan', updatedAt: DateTime.now())];
    // GAGAL saat dijalankan pada kode mentah AI karena menghasilkan empty list!
    expect(NoteSearchHelper.doSearch(list, 'belanja'), hasLength(1));
  });
  ```
* **Solusi Pembuktian & Perbaikan:**  
  Menambahkan normalisasi `.toLowerCase()` dan `.trim()` pada query maupun `note.title`:
  ```dart
  final trimmed = query.trim().toLowerCase();
  return notes.where((n) => n.title.toLowerCase().contains(trimmed)).toList();
  ```

---

## 3. Praktikum 3: Debug dan Refactor ke Clean Architecture

### 3.1. Alur Debugging dengan Test Merah
1. **Reproduksi:** Memasukkan judul catatan `"Belanja Bulanan"` lalu mencari dengan kata kunci `"belanja"` dan `"  belanja  "`. Hasil pencarian kosong.
2. **Isolasi:** Memindahkan seluruh tanggung jawab penyaringan catatan dari widget ke dalam *class* Use Case mandiri di `lib/domain/search_notes_use_case.dart`.
3. **Test Merah:** Menuliskan assertion di `test/search_filter_test.dart` yang menguji *case-insensitivity* dan *whitespace trimming*.
4. **Perbaikan:** Mengubah implementasi `execute()` di use case.
5. **Verifikasi:** Menjalankan test kembali hingga berstatus **HIJAU** (passed).

### 3.2. Struktur Layer Setelah Refactor
Arsitektur dipisahkan secara tegas mengikuti aturan *Clean Architecture*:

```
lib/
├── domain/                     <-- Pure Dart (Logika Bisnis Murni)
│   └── search_notes_use_case.dart
├── providers/                  <-- State Management (Riverpod)
│   └── notes_provider.dart    (searchQueryProvider & filteredNotesProvider)
├── data/                       <-- Penyimpanan & Database
│   ├── local/ (note.dart, db.dart)
│   └── repositories/ (note_repository.dart, prefs.dart)
└── main.dart                   <-- Presentation (UI Widget Saja)
    ├── _SearchInput
    ├── _NotesList (dengan Empty State)
    └── _NoteCard
```

- **Widget (UI Saja):** `_SearchInput` hanya mengirimkan input teks ke `searchQueryProvider`.
- **Notifier (State):** `searchQueryProvider` menyimpan query, `filteredNotesProvider` mengombinasikan data catatan dengan use case.
- **Use Case (Domain):** `SearchNotesUseCase` menjalankan algoritma filter tanpa peduli UI atau database.
- **Repository (Data):** `NoteRepository` tetap fokus pada persistensi SQLite.

---

## 4. AI Challenge: Review Kode & Matriks Keputusan

Setelah kode selesai di-refactor, AI diminta bertindak sebagai *Senior Code Reviewer* dengan prompt tantangan:
> *"Review kode search Flutter ini sebagai senior dev. Konteks: feature-first (presentation->domain<-data), Riverpod, SQLite. Fokus: kebenaran, arsitektur, test. Abaikan style. Beri 3 temuan + level blocker/saran + alasan."*

### Matriks Keputusan Usulan AI

| No | Temuan / Usulan AI | Level | Keputusan | Alasan Teknis & Bukti |
|:---:|:---|:---:|:---:|:---|
| **1** | **Saran:** Tambahkan pembersihan spasi (*trimming*) pada query pencarian sebelum diolah agar input seperti `" belanja "` tetap akurat. | *Medium* | **DITERIMA & DIIMPLEMENTASIKAN** | Pengguna mobile sering tidak sengaja menambahkan spasi di akhir kata karena fitur *autocomplete keyboard*. Dibuktikan dengan unit test `query dengan spasi di awal dan akhir otomatis ditrim` yang berhasil lolos. |
| **2** | **Saran:** Ganti filter di memori dengan query SQL `WHERE title LIKE ?` di database setiap kali user mengetik karakter baru. | *Blocker* | **DITOLAK** | **Alasan Penolakan:**<br>1. Data catatan pada aplikasi lokal ini berukuran kecil-menengah dan sudah di-*cache* di memori melalui `notesProvider`.<br>2. Melakukan I/O disk SQLite pada setiap *keystroke* menimbulkan *overhead* disk I/O yang tidak perlu.<br>3. Menggunakan SQL query pada widget merusak prinsip *offline-first* reaktif Riverpod dan mencampuradukkan layer presentasi dengan query database spesifik. |
| **3** | **Saran:** Pisahkan komponen `_SearchInput` dan `_NotesList` menjadi widget terpisah dengan kontrol state mandiri dan tambahkan status visual `Icons.search_off` saat empty state. | *Low* | **DITERIMA** | Menjaga ukuran class widget tetap modular di bawah 40 baris dan memberikan *feedback* UX yang jelas kepada pengguna saat catatan tidak ditemukan. |

---

## 5. Ringkasan Checklist Verifikasi Akhir

- [x] **Prompt 5-Slot Lengkap:** Tercatat di `doc/ai.logs.md`.
- [x] **Layer Domain Murni:** Bebas import `flutter`, `sqflite`, atau `dio`.
- [x] **1 Bug/Halusinasi AI Dibuktikan:** Bug *case-sensitive* dibuktikan dengan unit test merah sebelum diperbaiki.
- [x] **1 Saran AI Diterima & 1 Saran Ditolak:** Diterima (*trimming & modular widget*), Ditolak (*SQL LIKE per keystroke*).
- [x] **Unit & Widget Test:** 5 unit test di `test/search_filter_test.dart` dan 2 widget test di `test/widget_test.dart`.
- [x] **Statistik Linter & Format:** Memenuhi standar *Clean Architecture*.
