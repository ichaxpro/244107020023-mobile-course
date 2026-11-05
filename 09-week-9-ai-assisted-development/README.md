# Laporan Praktikum Pemrograman Mobile - Minggu 9
## Topik: AI-Assisted Development & Vibe Coding

* **NIM:** 244107020023
* **Mata Kuliah:** Pemrograman Mobile (Semester 5)
* **Program Studi:** D4 Teknik Informatika, Jurusan Teknologi Informasi, Politeknik Negeri Malang
* **Basis Proyek:** `05-week-5-local-storage-offline-first/week5_offline_notes`

---

## 1. Ringkasan Fitur yang Diimplementasikan

Pada praktikum Minggu 9 ini, ditambahkan satu fitur baru dengan memanfaatkan bantuan AI coding assistant secara terarah dan terukur:
1. **Pencarian Judul Catatan (*Search by Title*):** Pengguna dapat mencari catatan berdasarkan kata kunci judul secara reaktif dan *case-insensitive* (mengabaikan perbedaan huruf kapital/kecil).
2. **Pembersihan Otomatis (*Whitespace Trimming*):** Spasi di awal dan akhir kata kunci dihilangkan secara otomatis untuk mencegah kegagalan pencarian yang disebabkan oleh fitur *autocorrect/autocomplete* keyboard virtual.
3. **Status Kosong Dinamis (*Dynamic Empty State*):** 
   - Jika belum ada catatan sama sekali, aplikasi menampilkan instruksi: `"Belum ada catatan. Tekan + untuk menambah."`
   - Jika pengguna mencari dan kata kunci tidak ditemukan, aplikasi menampilkan ikon `Icons.search_off` disertai pesan: `"Tidak ada catatan dengan judul \"<query>\""`.
4. **Pembersihan Cepat (*Clear Query*):** Disediakan tombol silang (icon `clear`) di dalam search field untuk menghapus query dengan satu sentuhan.

---

## 2. Arsitektur Proyek (*Clean Architecture*)

Pemisahan tanggung jawab (*Separation of Concerns*) diterapkan secara ketat tanpa kompromi:

```
week5_offline_notes/
├── lib/
│   ├── domain/
│   │   └── search_notes_use_case.dart     <-- Domain Layer: Logika murni Dart (Zero-dependency UI/DB)
│   ├── providers/
│   │   └── notes_provider.dart            <-- State Management: Riverpod (searchQueryProvider & filteredNotesProvider)
│   ├── data/
│   │   ├── local/ (note.dart, db.dart)    <-- Data Layer: Model & database SQLite
│   │   └── repositories/ (note_repo.dart) <-- Data Layer: Repository SQLite
│   └── main.dart                          <-- Presentation Layer: UI Widgets (_SearchInput, _NotesList)
└── test/
    ├── search_filter_test.dart            <-- Unit Test untuk SearchNotesUseCase (5 test case)
    └── widget_test.dart                   <-- Widget Test untuk UI Search & Empty State
```

* **Presentation Layer (`main.dart`):** Menampilkan komponen `_SearchInput` dan `_NotesList`. Tidak ada pemanggilan SQLite langsung dari widget.
* **Domain Layer (`search_notes_use_case.dart`):** `SearchNotesUseCase` adalah pure Dart class yang bertugas memfilter koleksi `Note` berdasarkan string query. Bebas dari impor `package:flutter`, `sqflite`, atau `dio`.
* **State Management (`notes_provider.dart`):** `searchQueryProvider` mengelola string query saat ini, sementara `filteredNotesProvider` menggabungkan data catatan dari repository dengan use case domain secara reaktif.

---

## 3. Workflow AI & Verifikasi (Siklus 6 Tahap)

Pengembangan dilakukan melalui siklus:
$$\text{Prompt} \longrightarrow \text{Generate} \longrightarrow \text{Verify} \longrightarrow \text{Test} \longrightarrow \text{Refactor} \longrightarrow \text{Explain}$$

### 3.1. Formula Prompt 5-Slot
Prompt yang digunakan mencakup 5 komponen penting untuk mencegah *vibe coding* tak terkendali:
1. **Peran (*Role*):** Senior Flutter Developer (Clean Architecture expert).
2. **Konteks (*Context*):** Feature-first Flutter app, Riverpod state management, model `Note`.
3. **Tugas (*Task*):** Membuat fungsi pencarian judul catatan + widget empty state.
4. **Batasan (*Constraints*):** Wajib *pure Dart* di domain layer, fungsi $< 40$ baris, *case-insensitive*, tanpa membocorkan data rahasia.
5. **Output (*Deliverables*):** Use case, provider Riverpod, kode UI, dan skenario unit test.

*(Dokumentasi prompt lengkap, output awal AI, dan tabel keputusan dapat dilihat pada [docs/ai-log.md](docs/ai-log.md) atau [doc/ai.logs.md](doc/ai.logs.md)).*

---

## 4. Bukti Pengujian Mesin (*Machine Verification*)

### 4.1. Unit Test (`test/search_filter_test.dart`)
Pengujian unit mencakup 5 skenario pembuktian logika use case:
1. `query kosong kembalikan seluruh daftar catatan` $\rightarrow$ **PASSED**
2. `filter abaikan huruf besar/kecil (case-insensitive)` $\rightarrow$ **PASSED**
3. `query tak cocok kembalikan kosong (memicu empty state)` $\rightarrow$ **PASSED**
4. `query dengan spasi di awal dan akhir otomatis ditrim` $\rightarrow$ **PASSED**
5. `daftar catatan kosong tetap aman dan kembalikan kosong` $\rightarrow$ **PASSED**

### 4.2. Widget Test (`test/widget_test.dart`)
Pengujian widget memverifikasi interaktivitas tampilan UI:
1. `menampilkan status offline, dirty badge, dan search input` $\rightarrow$ **PASSED**
2. `filter catatan melalui search field dan tampilkan empty state saat tak cocok` $\rightarrow$ **PASSED**

### 4.3. Hasil Perintah Pengujian
```bash
# Analisis statis linter (0 issues)
flutter analyze
# Output: No issues found! (ran in 1.8s)

# Pengujian otomatis keseluruhan
flutter test
# Output: 00:03 +7: All tests passed!
```

---

## 5. Tangkapan Layar Tampilan Aplikasi (*Screenshots*)

Berikut adalah 3 skenario hasil pengujian tampilan aplikasi:

| Skenario 1: Tampilan Awal / Query Kosong | Skenario 2: Query Cocok (Case-Insensitive) | Skenario 3: Empty State (Tidak Ditemukan) |
| :---: | :---: | :---: |
| ![Query Kosong](screenshot/01_all_notes.png)<br>*(Menampilkan semua catatan yang tersimpan)* | ![Query Cocok](screenshot/02_search_matched.png)<br>*(Menampilkan hasil pencarian yang cocok)* | ![Empty State](screenshot/03_search_empty_state.png)<br>*(Menampilkan pesan & icon search_off)* |

> Catatan: Tangkapan layar juga tersimpan pada folder `screenshot/` dan `screenshots/`.

---

## 6. Refleksi Praktikum

### 1. Satu halusinasi / bug AI apa yang Anda temukan dan bagaimana membuktikannya?
**Jawaban:**  
Halusinasi dan bug logika yang ditemukan pada usulan awal AI adalah penyaringan catatan yang bersifat *case-sensitive* (`n.title.contains(query)` tanpa pemanggilan `.toLowerCase()`), serta penyertakan method helper yang menyarankan pemanggilan query SQL langsung dari layer UI.  
**Cara membuktikannya:** Dibuat pengujian unit pada `test/search_filter_test.dart` dengan memasukkan catatan bertitel `"Belanja Bulanan"` dan mencari dengan kata kunci `"belanja"`. Pada kode awal AI, assertion `expect(..., hasLength(1))` gagal (*test merah*) karena perbandingan karakter `B` kapital dan `b` kecil dianggap berbeda.

### 2. Prompt mana yang paling membantu dan apa yang Anda ubah?
**Jawaban:**  
Prompt yang paling membantu adalah prompt dengan **Formula 5-Slot** di mana kita secara eksplisit menetapkan slot *Batasan (Constraints)*: *"Pisahkan logika filter ke layer domain murni tanpa dependensi Flutter UI atau SQLite, dan fungsi di bawah 40 baris"*.  
Perubahan yang dilakukan dari prompt umum adalah: tidak sekadar meminta *"buatkan search notes"*, melainkan mendefinisikan kontrak input-output, arsitektur yang dipakai (`presentation -> domain <- data`), dan aturan dependensi secara spesifik.

### 3. Satu refactor apa yang Anda lakukan pada kode AI?
**Jawaban:**  
Refactoring terbesar adalah memindahkan seluruh logika penyaringan dari usulan AI (yang awalnya ditaruh di helper statis dengan impor `package:flutter/material.dart`) ke dalam sebuah *class use case* tersendiri di `lib/domain/search_notes_use_case.dart` yang murni berbasis Dart murni. Selain itu, pemanggilan state dihubungkan secara bersih ke Riverpod melalui `searchQueryProvider` dan `filteredNotesProvider`, sehingga widget `NotesPage` tetap bersih, deklaratif, dan modular.

### 4. Keputusan terima / tolak mana yang paling sulit dipertimbangkan?
**Jawaban:**  
Keputusan paling menuntut pertimbangan adalah saat AI menyarankan untuk mengeksekusi query database SQLite `WHERE title LIKE ?` langsung ke storage setiap kali pengguna mengetik satu karakter di `TextField`.  
Secara sekilas, pencarian via database terlihat seperti solusi standar (*enterprise*). Namun, setelah dievaluasi secara arsitektural dan performa:
1. Proyek ini menganut pola *offline-first* di mana seluruh daftar catatan aktif sudah dimuat dan di-*cache* secara aman di dalam memori oleh Riverpod (`notesProvider`).
2. Menjalankan disk I/O SQLite pada setiap *keystroke* dapat menyebabkan latensi UI dan *overhead* I/O yang mubazir pada perangkat mobile.
3. Oleh karena itu, usulan tersebut **DITOLAK**, dan dipilih pendekatan penyaringan in-memory di layer domain use case murni yang cepat, reaktif, dan mudah diuji secara modular tanpa ketergantungan mock database.
