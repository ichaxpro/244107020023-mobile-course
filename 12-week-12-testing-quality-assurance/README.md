# Testing & Quality Assurance - Week 12

Dokumentasi pengujian untuk fitur **Local Storage & Offline-First Notes** dari
Week 5. Pengujian mencakup logika pencarian, model `Note`, repository SQLite,
tampilan widget, dan alur aplikasi melalui integration test.

## 1. Skenario yang Diuji

### Unit test

File: `test/search_filter_test.dart`

- Query kosong mengembalikan seluruh catatan.
- Pencarian tidak membedakan huruf besar dan kecil.
- Query yang tidak cocok mengembalikan daftar kosong untuk empty state.
- Spasi di awal dan akhir query diabaikan.
- Daftar catatan kosong tetap aman.
- Query yang hanya berisi spasi dianggap kosong.
- Pencarian sebagian kata pada judul berhasil.
- `Note.toMap()` menghasilkan seluruh field dengan nilai yang benar.
- `Note.fromMap()` dapat membangun kembali objek `Note`.
- `updated_at` yang tidak valid menggunakan nilai epoch.
- Nilai `dirty` dikonversi dengan benar.

### Repository test

File: `test/note_repository_test.dart`

- Database SQLite in-memory dapat dibuat untuk pengujian.
- `fetchNotes()` mengembalikan daftar kosong pada database baru.
- `fetchNotes()` mengembalikan catatan dalam urutan terbaru.
- `addNote()` menghasilkan ID valid dan `dirty = true`.
- Body kosong menggunakan default string kosong.
- `deleteNote()` menghapus catatan dari database.
- `countDirty()` menghitung catatan yang belum tersinkron.
- `markAllSynced()` mengubah seluruh flag `dirty` menjadi `false`.
- `syncNotes()` mengembalikan `0` jika tidak ada catatan dirty.
- `syncNotes()` mengembalikan jumlah catatan yang disinkronkan dan mereset
  flag dirty.

### Widget test

File: `test/widget_test.dart`

- Halaman menampilkan judul **Catatan Offline**.
- Badge jumlah catatan yang belum tersinkron tampil dengan benar.
- Input pencarian dan catatan awal tampil.
- Catatan dengan status dirty menampilkan label **Dirty**.
- Pencarian dengan hasil yang cocok menampilkan jumlah hasil.
- Pencarian tanpa hasil menampilkan empty state dan ikon pencarian.

### Integration test

File: `integration_test/app_test.dart`

- Aplikasi terbuka dan menampilkan halaman Catatan Offline.
- Badge dirty count tampil berdasarkan provider yang dioverride.
- Catatan dari stub provider tampil pada layar.
- Pengguna dapat mengetik query pada search field.
- Hasil pencarian yang cocok tetap ditampilkan.
- Query yang tidak cocok menghilangkan catatan dan menampilkan empty state.

## 2. Hasil Pengujian

Hasil pengujian menunjukkan bahwa static analysis tidak menemukan masalah,
unit/widget test berhasil, dan alur integration test dapat dijalankan dengan
stub provider. Stub tersebut membuat hasil pengujian tidak bergantung pada
database atau jaringan nyata.

### Bukti `flutter analyze`

![Hasil flutter analyze](<screenshot/flutter%20analyze.png>)

### Bukti `flutter test`

![Hasil flutter test](<screenshot/flutter_test.png>)

### Bukti integration test

![Hasil integration test](<screenshot/app_test.png>)

## 3. Jawaban Refleksi

### Bug apa yang paling mungkin terlewat tanpa pengujian yang ditulis?

Bug yang paling mungkin terlewat adalah kesalahan pada kondisi batas pencarian
dan status sinkronisasi. Tanpa unit test, query dengan huruf besar/kecil,
spasi, sebagian kata, query tanpa hasil, atau daftar kosong dapat menghasilkan
daftar yang salah atau empty state yang tidak muncul. Tanpa repository test,
kesalahan pada konversi `dirty`, penghapusan catatan, pengurutan berdasarkan
`updated_at`, serta proses `syncNotes()` dapat membuat catatan terlihat
tersimpan tetapi tidak pernah tersinkron.

Widget dan integration test juga menangkap bug yang tidak terlihat dari unit
test saja, misalnya search field tidak terhubung ke filter, badge dirty count
tidak tampil, atau teks empty state dan ikon pencarian tidak muncul pada alur
pengguna yang sebenarnya.

### Bagian mana yang perlu fake, dan bagaimana fake itu membuat pengujian lebih konsisten?

Database pada repository test dibuat sebagai SQLite in-memory menggunakan
`sqflite_common_ffi`. Dengan cara ini, setiap test memakai database sementara
yang dapat dibuat dan ditutup kembali tanpa menyentuh database perangkat.
Hasilnya lebih cepat, terisolasi, dan tidak dipengaruhi data test sebelumnya.

Pada widget dan integration test, provider catatan, dirty count, dan status
offline dioverride dengan notifier stub. Fake provider mengembalikan data yang
tetap, sehingga test tidak bergantung pada jaringan, waktu sinkronisasi,
SharedPreferences, atau isi database lokal. Integration test dapat fokus pada
alur UI dan interaksi pengguna, bukan pada keberhasilan layanan eksternal.

### Apa perbedaan nilai yang diberikan pengujian widget dan pengujian integrasi pada fitur Anda?

Widget test memeriksa satu bagian UI secara terisolasi. Pengujian ini cepat dan
tepat untuk memastikan widget menampilkan judul, badge, input pencarian,
catatan, hasil filter, dan empty state ketika provider memberikan data tertentu.

Integration test memeriksa alur yang lebih dekat dengan penggunaan nyata:
aplikasi dibuka, provider dipasang, pengguna mengetik pada search field, lalu
layar berubah dari daftar catatan menjadi hasil pencarian atau empty state.
Karena cakupannya lebih luas, integration test dapat menemukan masalah
keterhubungan antar-widget, provider, dan navigasi/alur aplikasi yang mungkin
tidak terlihat pada widget test, meskipun waktu eksekusinya lebih lama.