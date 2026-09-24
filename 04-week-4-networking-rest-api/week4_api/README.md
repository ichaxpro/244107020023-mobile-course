# Week 3: Networking & REST API

**Name:** Dewi Chalissa Rania  
**Class:** TI 3I  
**NIM:** 244107020023  

---

## 📋 Checklist

- [x] UI tidak memanggil Dio langsung, semua akses data lewat repository + provider.
- [x] Empat state tampil benar: loading, error (+ retry), empty, success.
- [x] Pagination: data bertambah saat scroll, tidak ada request ganda, ada indikator akhir data.
- [x] flutter analyze tanpa issue dan semua test lulus.
- [x] Hasil AI diverifikasi dan didokumentasikan pada folder docs/.

## Practicum 2
### Result
1. <img src="images\prac2_1.png" width="350" alt="Warmup Result">
2. <img src="images\prac2_2.png" width="350" alt="Warmup Result">
3. <img src="images\prac2_3.png" width="350" alt="Warmup Result">

## Practicum 3
### Result
<img src="images\prac3.png" width="350" alt="Warmup Result">

## AI Challenge
### AI tools: Copilot
### AI Prompt
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error
  ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
### AI Verification Checklist
1. UI memanggil Dio langsung? 
Answer: Tidak ditemukan. Dio dipakai oleh repository melalui provider. Namun commentsProvider belum digunakan oleh halaman UI mana pun.
2. fromJson aman terhadap null/field hilang? 
Answer: Ya. Comment.fromJson memakai as num?, as String?, dan nilai default. Tidak ada cast langsung yang berisiko crash.
3. Mapping error Dio?
Answer: Ya, untuk kebutuhan utama. Timeout (connectionTimeout, sendTimeout, receiveTimeout), connectionError, dan badResponse sudah dipetakan. Status 404 dan 500 juga memiliki pesan khusus.
4. baseUrl dan timeout terpusat?
Answer: Sebagian. baseUrl terpusat di api_client.dart, tetapi timeout 10 detik didefinisikan di api_client.dart dan di comment_repository.dart. Ini perlu dirapikan pada perubahan berikutnya.
5. Test field hilang?
Answer: Ya. comment_test.dart menguji JSON tanpa postId, name, dan body, bukan hanya happy path.
## Refactoring & Testing
### Result
<img src="images\refactor1.png" width="350" alt="Warmup Result">
<img src="images\refactor2.png" width="350" alt="Warmup Result">
<img src="images\flutter_analyze.png" width="350" alt="Warmup Result">

## Refleksi
1. Why is the UI forbidden from calling Dio directly? What breaks if this rule is violated?
Answer: It mixes presentation and networking logic, making widgets harder to test, reuse, and maintain. Violating this rule causes duplicated error handling, tight coupling, and more difficult mocking.
2. When is client-side pagination enough, and when must you rely on server pagination (_page/_limit)?
Answer: Client-side pagination is enough for small datasets already loaded locally. Use server pagination with _page/_limit for large datasets, limited bandwidth, slow devices, or APIs that return data incrementally.
3. How do repository exceptions become AsyncError without try/catch in every widget? When is explicit try/catch still needed?
Answer: AsyncNotifier.build() automatically catches exceptions from the repository and exposes them as AsyncError through Riverpod. Explicit try/catch is still useful for custom recovery, retry logic, logging, transforming errors, or handling errors inside user-triggered actions.
4. Which part of the AI output did you fix, and why?
Answer: I replaced the invalid FamilyAsyncNotifier implementation with the Riverpod 3-compatible AsyncNotifierProvider.family pattern. This was necessary because the original code failed analysis with undefined API errors.
