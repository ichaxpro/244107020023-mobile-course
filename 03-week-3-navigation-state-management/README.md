# Week 3: Navigation & State Management

**Name:** Dewi Chalissa Rania  
**Class:** TI 3I  
**NIM:** 244107020023  

---

## 📋 Checklist

- [x] `Navigasi GoRouter bekerja: pindah halaman, back, dan akses path detail langsung.
- [x] ProviderScope membungkus root aplikasi; state ToDo bertahan saat berpindah halaman.
- [x] UI AsyncValue menangani loading, error, dan success, bukan hanya success.
- [x] flutter analyze tanpa issue dan semua test lulus.
- [x] Hasil AI diverifikasi dan didokumentasikan pada folder docs/.

---
## Praktikum 1 — Aplikasi multi-page dengan GoRouter
<img src="week3_navigation\image\result1.png" width="350" alt="Warmup Result">
<img src="week3_navigation\image\result2.png" width="350" alt="Warmup Result">

---
## Praktikum 2 — Aplikasi ToDo dengan Riverpod
<img src="week3_todo\images\result_todo.png" width="350" alt="Warmup Result">
<img src="week3_todo\images\result_todo1.png" width="350" alt="Warmup Result">

---
## Praktikum 3 — Uji ketiga state
<img src="asyncvalue\image\result.png" width="350" alt="Warmup Result">

### 1. Loading Page
<img src="asyncvalue\image\loading.png" width="350" alt="Warmup Result">

### 2. UI error
<img src="asyncvalue\image\UI_error.png" width="350" alt="Warmup Result">

### 3. Why is displaying stale data with a refresh indicator sometimes better than clearing the screen, and when is this pattern important?
Displaying stale data with a refresh indicator (often called the stale-while-revalidate pattern) is much better because it maintains a smooth user experience, prevents jarring layout shifts, and allows users to keep reading existing information while fresh data loads in the background.

---
## AI Challenge
### AI Tool: Copilot
### AI prompt:
Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
Requirements:
- ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
  pengambilan data statistik (delay 2 detik, kadang gagal 30%).
- UI harus menangani loading (spinner), error (pesan + tombol retry),
  dan success (ListView 3 item).
- Berikan unit test untuk notifier-nya.
Jelaskan setiap bagian kode dalam komentar.

### Result
<img src="ai_verification\image\result.png" width="350" alt="Warmup Result">


---

## Refactoring Challenge
### Result
<img src="week3_todo\images\result_stat.png" width="350" alt="Warmup Result">

### Flutter Analyze and Test
<img src="week3_todo\images\analyze_test.png" width="350" alt="Warmup Result">

---

## Reflection
1. When is setState still sufficient, and when should state be elevated to Riverpod?
Answer: setState is still sufficient for managing local state that only affects a single widget, such as toggle states, local animations, or simple form inputs. Conversely, state should be elevated to Riverpod when the data is global, needs to be shared across multiple widgets on different screens, or must persist outside a specific widget's lifecycle.
2. What is the difference between context.go and context.push, and when is each appropriately used?
Answer:context.go replaces the current route in the navigation stack and is ideal for top-level navigation like main tab menus or logout buttons. Meanwhile, context.push stacks a new route on top of the existing one without removing it, making it perfect for branching flows such as opening a detail page from a list.
3. How does AsyncValue prevent bugs compared to three separate booleans?
Answer: AsyncValue prevents bugs by combining isLoading, hasError, and data into a single sealed object that forces developers to safely handle all possible states. Using three separate booleans is highly error-prone because it allows invalid logical states to occur simultaneously, such as both loading and error being true at the same time.
4. Which part of the AI output did you fix, and why?
Answer: The corrected part emphasizes the aspect of preventing memory leaks and automatic memory management in Riverpod, ensuring the explanation focuses not just on UI convenience but also on clean code architecture standards.