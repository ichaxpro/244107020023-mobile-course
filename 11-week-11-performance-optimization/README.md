## Refleksi
1. **Optimasi mana yang memberikan dampak terbesar dan mengapa?**
   Optimasi yang memberikan dampak terbesar adalah mengurangi pekerjaan yang dilakukan
   pada setiap rebuild, misalnya dengan menggunakan `const`, memecah widget menjadi
   bagian yang lebih kecil, dan menghindari pemanggilan proses berat di dalam `build`.
   Dampaknya besar karena Flutter harus menjalankan proses build dan layout berulang
   kali saat UI berubah. Semakin sedikit widget dan proses yang dihitung ulang, semakin
   kecil beban CPU dan semakin lancar frame yang dihasilkan.

2. **Bagaimana Anda memverifikasi bahwa optimasi benar-benar bekerja (bukan placebo)?**
   Saya membandingkan kondisi sebelum dan sesudah optimasi menggunakan Flutter DevTools
   dalam mode profile. Saya mengukur frame rendering, penggunaan CPU dan memori, serta
   waktu respons saat melakukan aksi yang sama beberapa kali. Optimasi dianggap berhasil
   jika hasil pengukuran menunjukkan frame lebih konsisten, jank berkurang, dan waktu
   respons membaik, bukan hanya berdasarkan kesan subjektif saat mencoba aplikasi.

3. **Trade-off apa yang Anda hadapi (misalnya kompleksitas kode vs performa)?**
   Trade-off utamanya adalah kode menjadi lebih terstruktur dan kadang lebih kompleks
   karena widget perlu dipecah, state perlu dikelola lebih hati-hati, atau data perlu
   di-cache. Caching dapat mempercepat akses, tetapi meningkatkan penggunaan memori dan
   membutuhkan invalidasi data agar tidak menampilkan informasi lama. Karena itu,
   optimasi diterapkan hanya pada bagian yang terbukti menjadi bottleneck.

4. **Kapan sebaiknya optimasi premature dihindari?**
   Optimasi premature sebaiknya dihindari ketika fitur dan alur aplikasi belum stabil,
   bottleneck belum diketahui, atau perubahan hanya dilakukan berdasarkan asumsi.
   Fokus awal sebaiknya pada kode yang benar, mudah dibaca, dan mudah diuji. Setelah
   dilakukan profiling dan ditemukan masalah performa yang nyata, barulah optimasi
   diterapkan dan diverifikasi dengan pengukuran.
