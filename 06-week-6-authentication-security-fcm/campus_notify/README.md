# Campus Notify 📢

A Flutter mobile application for campus announcements using **Firebase Cloud Messaging (FCM)**, **Flutter Local Notifications**, **Riverpod**, **GoRouter**, and **Flutter Secure Storage**.

---

## 📱 App Description & Login Pattern

- **App Description**: Campus Notify delivers real-time campus announcements and push notifications to students across all mobile lifecycle states.
- **Login Pattern & Guard**:
  - Auth tokens (`access_token` & `refresh_token`) are stored securely using `FlutterSecureStorage` ([lib/data/token_store.dart](file:///C:/244107020023-mobile-course/06-week-6-authentication-security-fcm/campus_notify/lib/data/token_store.dart)).
  - `GoRouter` enforces a route guard ([lib/main.dart](file:///C:/244107020023-mobile-course/06-week-6-authentication-security-fcm/campus_notify/lib/main.dart)) redirecting unauthenticated users to `/login`.
  - `Dio` interceptor ([lib/data/api_client.dart](file:///C:/244107020023-mobile-course/06-week-6-authentication-security-fcm/campus_notify/lib/data/api_client.dart)) automatically refreshes the JWT access token once upon HTTP `401`, and forces logout/clears storage if refresh fails.

---

## 🧪 3-State Test Table + Screenshots

All three app lifecycle states were tested with the payload `{"route": "/announcement/3"}`:

| State | Expected Behavior | How to Test | Status |
| --- | --- | --- | --- |
| **Foreground** | Local notification banner appears. Tapping it navigates to `/announcement/3`. | App open on screen, send FCM message from console/backend. | **PASSED** |
| **Background** | Android system notification banner appears. Tapping it opens app & routes to `/announcement/3`. | Press Home button, send FCM message, tap notification. | **PASSED** |
| **Terminated** | App launches from cold start via `getInitialMessage()` & routes directly to `/announcement/3`. | Swipe-close app completely, send FCM message, tap notification. | **PASSED** |

### Screenshots Evidence
- <img src="image\banner_notification.jpeg" width="350" alt="Warmup Result">
- <img src="image\announcement_detail.jpeg" width="350" alt="Warmup Result">
- <img src="image\login_page.jpeg" width="350" alt="Warmup Result">



---


## 🚀 How to Run

1. Connect a physical Android phone with USB Debugging enabled.
2. Fetch dependencies and run static analysis:
   ```bash
   flutter pub get
   flutter analyze
   ```
3. Run unit & widget tests:
   ```bash
   flutter test
   ```
4. Build and run application on the connected physical device:
   ```bash
   flutter run
   ```

---

## 🤖 AI Tools Used

- **Google Antigravity AI Assistant (Gemini 3.6 Flash)**: Used for FCM architecture design, `PushService` implementation, route guard refactoring, and test suite creation.

---

## 💬 Prompt + Manual Fixes

### AI Prompt Used:
> *Flutter Campus Notification App. Stack: firebase_messaging, flutter_local_notifications, flutter_secure_storage, go_router, Riverpod. Generate a PushService with: requestPermission + getToken + onTokenRefresh (send to POST /devices), onMessage (show a local notification manually), onMessageOpenedApp + getInitialMessage (navigate to data.route), subscribe/unsubscribe topic campus-announcement, top-level background handler with @pragma('vm:entry-point'). Mark which parts DIFFER for Android 13+ vs iOS, and which parts must never touch BuildContext.*

### Manual Fixes Applied:
1. **Android 13+ Notification Permission & Desugaring**: Added `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` in `AndroidManifest.xml` and enabled `isCoreLibraryDesugaringEnabled = true` in `build.gradle.kts`.
2. **GoRouter Guard Deep-Link Bypass**: Updated `redirect` logic in `lib/main.dart` to allow public announcement routes (`/announcement/:id`) without being blocked by `/login`.
3. **Local Notification Tap Syntax & Callback**: Fixed `InitializationSettings` parameter name syntax (`settings:`) and bound `_onRouteTap` callback to navigate immediately on tap.

---

## 🐛 Issues Found & Test Results

### Issues Found & Resolved:
- **Build Failure (Desugaring)**: `flutter_local_notifications` failed build due to missing Java 8 desugaring in Android Gradle. *Fixed via `build.gradle.kts`.*
- **Missing Navigation**: Foreground notification taps failed to trigger GoRouter navigation. *Fixed via `routeFromMessage` and `listenForeground` callbacks.*

### Verification & Test Results:
- **`flutter analyze`**:
<img src="image\flutter_analyze.png" width="350" alt="Warmup Result">

- **`flutter test`**:
<img src="image\flutter_test.png" width="350" alt="Warmup Result">


---

## 💡 Reflection Answers

### Q1: Why must refresh tokens never live in SharedPreferences? What is the risk if one leaks?
- **Technical Answer**: `SharedPreferences` on Android stores data in unencrypted, plain-text XML files (`/data/data/<package>/shared_prefs/`). Anyone with root access, a physical device connection, or backup extraction tools can read plain-text tokens. `FlutterSecureStorage` uses hardware-backed Keystore (Android) / Keychain (iOS) encryption.
- **Risk if leaked**: Refresh tokens typically have long lifespans (weeks or months). If an attacker steals a refresh token, they can generate valid access tokens continuously without knowing the user's password, leading to persistent account takeover.

### Q2: What breaks if `onTokenRefresh` is ignored for a whole semester?
- **Technical Answer**: FCM registration tokens periodically rotate or invalidate (e.g. when app data is restored, OS updates occur, or Google Play Services rotates tokens).
- **Consequence**: If `onTokenRefresh` is ignored, the backend holds a stale token. Important push notifications (exam alerts, grade announcements, tuition reminders) sent to that device will fail silently with `NotRegistered` / `UNREGISTERED` errors.

### Q3: When do you use a topic vs a device token? Give one campus message example for each.
- **Topic Messaging**: Used for **broadcasts** to a group or all users without needing individual token management.
  - *Campus Example*: *"Kampus Libur: Seluruh kegiatan perkuliahan ditiadakan pada hari libur nasional besok."* (Topic: `campus-announcement`).
- **Device Token Messaging**: Used for **targeted, sensitive, or user-specific** notifications.
  - *Campus Example*: *"Pemberitahuan Khusus: Pembayaran UKT Semester Genap atas nama [Nama Mahasiswa] telah diverifikasi LUNAS."* (Device Token).

### Q4: Which part of the AI draft did you reject or fix, and why?
- **Rejections & Fixes**:
  1. **Android 13+ Permission & Desugaring**: Initial AI boilerplate omitted `POST_NOTIFICATIONS` in `AndroidManifest.xml` and `isCoreLibraryDesugaringEnabled` in Gradle. Without these, builds fail or notifications are blocked silently on Android 13+.
  2. **GoRouter Guard Blocking Deep Links**: Initial AI draft route guards redirected unauthenticated deep link navigation to `/login`. Fixed the guard redirect logic to allow public announcement routes (`/announcement/:id`).
  3. **Foreground Banner Callbacks**: Fixed `InitializationSettings` parameter syntax for `flutter_local_notifications` and bound tap callbacks (`_onRouteTap`) so local notification clicks trigger `router.go(route)`.



# 07 | Clean Architecture
## Audit Arsitektur - Week 7

### 1. Pemetaan File ke Layer
| File | Layer saat ini | Masalah |
| :--- | :--- | :--- |
| `lib/pages/*` | Presentation | Bebas dari panggilan API langsung dan format data |
| `lib/providers/auth_provider.dart` | Presentation (State) | Instansiasi manual `AuthRepository()` langsung tanpa injeksi dependency |
| `lib/data/auth_repository.dart` | Data | Kontrak (interface) dan implementasi masih tergabung dalam satu kelas konkret |

### 2. Temuan Tiga Pelanggaran Klasik
- **Akses Jaringan/DB di Widget:** 0 temuan
- **Logika Bisnis di build():** 0 temuan
- **Instansiasi Manual (DI Bocor):** 
  - `lib/providers/auth_provider.dart:6` -> `final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());`

### 3. Struktur Target (Clean Architecture)
```text
lib/
├── core/
│   ├── failures.dart
│   └── providers.dart
├── features/
│   └── auth/ (atau notifications/)
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/auth_repository.dart       # Interface/Abstract class
│       │   └── usecases/
│       ├── data/
│       │   ├── models/
│       │   └── repositories/auth_repository_impl.dart  # Implementasi konkret
│       └── presentation/
│           ├── providers/auth_providers.dart
│           └── pages/
└── routes.dart
```

---
## Lab 3 Week 7
### Result
<img src="image\lab3_week7.png" width="350" alt="Warmup Result">

## 🤖 6. AI Challenge: Clean Architecture Reorganization Week 7

### 💬 AI Prompt Used:
> *My Flutter project: campus_notify (auth + FCM + announcement list).*  
> *Current state: lib/{data, providers, pages, messaging} folders, repositories mixed with implementations, widgets calling Dio directly.*  
> *Tasks:*  
> *1. Propose a feature-first Clean Architecture structure (presentation/domain/data) for the auth + announcements features.*  
> *2. For each old file, state its new destination (move/split/delete).*  
> *3. Flag what would be over-engineering if applied to simple CRUD, and when a use case is truly needed vs repository straight to notifier.*  
> *4. Show the Riverpod DI wiring (no extra DI package).*  
> *Explain the trade-off of every decision.*

---

### 1. Struktur Target (Feature-First Clean Architecture)
```text
lib/
├── core/                                     # Utilitas & infrastruktur global
│   ├── errors/
│   │   └── failures.dart                    # Pure Dart sealed class
│   ├── network/
│   │   ├── api_client.dart                  # Dio instance & interceptor refresh token
│   │   └── api_errors.dart                  # Parser error HTTP / Dio
│   └── storage/
│       └── token_store.dart                 # FlutterSecureStorage wrapper
│
├── features/
│   ├── auth/                                # Fitur Otentikasi
│   │   ├── domain/                          # Murni Dart, BEBAS Flutter/Dio/Storage
│   │   │   ├── entities/
│   │   │   │   └── auth_session.dart        # Entity murni (tanpa fromJson/toJson)
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart     # Interface (Abstract class)
│   │   │   └── usecases/
│   │   │       └── login_usecase.dart       # Orkestrasi login + simpan token
│   │   ├── data/                            # Implementasi konkret & serialisasi
│   │   │   ├── models/
│   │   │   │   └── auth_session_model.dart  # Parser JSON / Token
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart# Implementasi konkret AuthRepository
│   │   └── presentation/                    # UI & State Riverpod
│   │       ├── providers/
│   │       │   └── auth_providers.dart      # Notifier & DI wiring
│   │       └── pages/
│   │           └── login_page.dart          # ConsumerWidget
│   │
│   └── announcements/                       # Fitur Pengumuman Kampus
│       ├── domain/
│       │   ├── entities/
│       │   │   └── announcement.dart        # Entity murni
│       │   └── repositories/
│       │       └── announcement_repository.dart # Interface
│       │   # (Tidak ada use case untuk CRUD sederhana -> mencegah over-engineering)
│       ├── data/
│       │   ├── datasources/
│       │   │   └── announcement_remote_datasource.dart # Akses langsung ke Dio
│       │   ├── models/
│       │   │   └── announcement_model.dart  # Serialisasi fromJson / toJson
│       │   └── repositories/
│       │       └── announcement_repository_impl.dart
│       └── presentation/
│           ├── providers/
│           │   └── announcement_providers.dart # FutureProvider langsung dari Repo
│           └── pages/
│               ├── announcement_list_page.dart # Beranda daftar pengumuman
│               └── announcement_detail_page.dart # Detail pengumuman (#id)
│
├── messaging/                               # Layanan Push Notification (FCM)
│   └── push_service.dart                    # Background handler, token refresh, local notification
├── routes.dart                              # GoRouter guard & navigasi
└── main.dart                                # Entry point aplikasi
```

---

### 2. Pemetaan File Lama ke Lokasi Baru (Move / Split / Delete)

| File Lama | Status | Tujuan Baru | Alasan Teknis |
| :--- | :--- | :--- | :--- |
| `lib/data/auth_repository.dart` | **SPLIT** | 1. `features/auth/domain/entities/auth_session.dart`<br>2. `features/auth/domain/repositories/auth_repository.dart`<br>3. `features/auth/data/models/auth_session_model.dart`<br>4. `features/auth/data/repositories/auth_repository_impl.dart` | Memisahkan kontrak *interface* dari implementasi konkret, serta memisahkan *entity* murni dari *model* serialisasi JSON/token. |
| `lib/data/api_client.dart` | **MOVE** | `lib/core/network/api_client.dart` | Client Dio adalah utilitas bersama lintas fitur. |
| `lib/data/api_errors.dart` | **MOVE** | `lib/core/network/api_errors.dart` | Utilitas parsing status code & error jaringan bersama. |
| `lib/data/token_store.dart` | **MOVE** | `lib/core/storage/token_store.dart` | Wrapper `FlutterSecureStorage` merupakan resource infrastruktur bersama. |
| `lib/providers/auth_provider.dart` | **REFACTOR** | `features/auth/presentation/providers/auth_providers.dart` | Mengganti instansiasi manual `AuthRepository()` dengan injeksi *interface* via Riverpod. |
| `lib/pages/login_page.dart` | **MOVE** | `features/auth/presentation/pages/login_page.dart` | Halaman login dikelompokkan ke dalam fitur `auth`. |
| `lib/pages/home_page.dart` | **RENAME/MOVE** | `features/announcements/presentation/pages/announcement_list_page.dart` | Menampilkan daftar pengumuman kampus. |
| `lib/pages/announcement_page.dart` | **RENAME/MOVE** | `features/announcements/presentation/pages/announcement_detail_page.dart` | Menampilkan detail isi pengumuman sesuai route payload FCM. |
| `lib/messaging/push_service.dart` | **KEEP** | `lib/messaging/push_service.dart` | Berada di level infrastruktur background OS (FCM & local notifications). |

---

### 3. Analisis Over-Engineering vs Kebutuhan Nyata Use Case

* **Kapan Use Case Tergolong Over-Engineering?**  
  Pada fitur pengumuman (*announcements*), operasi hanya berupa pengambilan data (*read*) sederhana (`getAnnouncements()`). Membuat kelas khusus `GetAnnouncementsUseCase` yang isinya hanya 1 baris memanggil `_repo.getAnnouncements()` adalah **over-engineering** karena hanya menambah *boilerplate* dan *indirection* tanpa ada aturan bisnis. Menghubungkan Repository langsung ke `FutureProvider` / `Notifier` jauh lebih bersih dan efisien.

* **Kapan Use Case Benar-Benar Dibutuhkan?**  
  Use case wajib dibuat pada skenario:
  1. **Orkestrasi Multi-Repository / Data Source**: Misalnya pada `LoginUseCase`, alurnya melibatkan pemanggilan `AuthRepository.login()`, penyimpanan token ke `TokenStore.save()`, dan sinkronisasi token FCM ke backend. Logika gabungan ini tidak boleh bocor ke UI/Notifier.
  2. **Aturan Validasi & Bisnis Kompleks**: Validasi format email domain kampus, evaluasi kedaluwarsa token, atau sanitasi input.
  3. **Dapat Digunakan Ulang (Reusable)**: Dapat dipanggil dari berbagai UI controller berbeda (misal form login biasa dan deep-link auto-login).

---

### 4. Riverpod Dependency Injection Wiring

```dart
// --- 1. CORE INFRASTRUCTURE ---
final apiClientProvider = Provider<Dio>((ref) => ApiClient.create());
final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

// --- 2. AUTH FEATURE WIRING ---
// Data Layer (Konkret)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

// Domain Layer (Use Case menerima interface abstraksi)
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    tokenStore: ref.watch(tokenStoreProvider),
  );
});

// Presentation Layer (State Notifier)
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, bool>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final token = await ref.watch(tokenStoreProvider).readAccess();
    return token != null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(loginUseCaseProvider).execute(email: email, password: password);
      return true;
    });
  }
}

// --- 3. ANNOUNCEMENTS WIRING (Direct Repo -> Provider) ---
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl(
    remoteDataSource: AnnouncementRemoteDataSource(ref.watch(apiClientProvider)),
  );
});

final announcementsProvider = FutureProvider<List<Announcement>>((ref) async {
  return ref.watch(announcementRepositoryProvider).getAnnouncements();
});
```

---

### 5. Analisis Trade-Off Desain

* **Feature-First vs Layer-First**: Struktur folder sedikit lebih dalam (*nested*), namun setiap fitur mandiri, mudah dirawat, dan skalabel ketika fitur bertambah.
* **Interface (Domain) vs Implementation (Data)**: Membutuhkan 2 file (interface & impl), namun kode UI dan testing terisolasi dari perubahan framework atau sumber data.
* **Entity Murni (Tanpa `fromJson`/`toJson`)**: Memerlukan kelas `Model` pendamping di layer data, namun layer domain tetap 100% independen terhadap format payload backend.

---

### 📋 AI Verification Checklist & Temuan Evaluasi

| Kriteria Verifikasi | Status Evaluasi | Analisis Teknis |
| :--- | :--- | :--- |
| **1. Repository interface di domain, implementasi di data?** | **Lolos (Verified)** | `AuthRepository` & `AnnouncementRepository` (abstract class) berada di `domain/repositories/`, sedangkan `AuthRepositoryImpl` & `AnnouncementRepositoryImpl` berada di `data/repositories/`. Tidak digabung dalam satu folder. |
| **2. Domain bebas import Flutter / Dio / SQLite / Firebase?** | **Lolos (Verified)** | Diverifikasi dengan `rg`: Layer `domain/` hanya mengimpor tipe murni Dart dan `core/errors/failures.dart`. Tidak ada ketergantungan pada UI framework atau library pihak ketiga. |
| **3. Tidak membuat Use Case untuk CRUD 1-baris sederhana?** | **Lolos (Verified)** | Pada fitur `announcements`, pemanggilan langsung dari Repository ke `FutureProvider` tanpa membuat `GetAnnouncementsUseCase` untuk menghindari *over-engineering*. |
| **4. Entity bebas mapping (`toMap`/`fromMap`/`toJson` hanya di Model)?** | **Lolos (Verified)** | `AuthSession` dan `Announcement` murni entitas data Dart. Fungsi serialisasi JSON hanya didefinisikan pada `AuthSessionModel` dan `AnnouncementModel` di layer data. |
| **5. DI terpusat di Riverpod providers tanpa instansiasi manual di Widget?** | **Lolos (Verified)** | Semua dependensi di-*wire* melalui Riverpod `Provider`. Widget hanya menggunakan `ref.watch` atau `ref.read`, tanpa memanggil `new AuthRepository()`. |
| **6. Keputusan Akhir & Rationale Teknis** | **Diterima (Accepted)** | Arsitektur yang diajukan seimbang: menerapkan pemisahan tugas secara ketat pada fitur kompleks (`auth`), namun pragmatis dan tidak *over-engineered* pada fitur baca sederhana (`announcements`). |

## Reflection Week 7

### Q1: Why must the repository interface live in domain, not in data? What breaks if it is reversed?
- **Technical Answer**: The domain layer defines the business contract that the application needs, while the data layer provides one implementation of that contract. This follows the Dependency Inversion Principle: domain and presentation depend on an abstraction, not on Dio, SQLite, Firebase, or another infrastructure detail.
- **If reversed**: If the interface is owned by the data layer, the domain must import or know about a data-layer package. A change from REST to SQLite, or from Dio to another client, can then force changes in use cases and UI code. Tests also become harder because the domain is coupled to data concerns instead of accepting a simple fake repository.

### Q2: When is a use case truly needed, and when is repository straight to notifier enough?
- **Use a use case when** the operation contains business rules, validation, orchestration across multiple repositories or data sources, side effects, or a workflow that can be reused by more than one presentation flow. For example, login can coordinate authentication, secure token storage, and FCM token synchronization without putting that workflow in a notifier.
- **Repository straight to notifier is enough when** the operation is a simple pass-through with no additional business decision, such as loading an announcements list and returning the repository result. In that case, adding a use case only to call one repository method adds indirection without protecting a meaningful rule.

### Q3: What does over-engineering (a use case per one-line CRUD) cost a small team? When is the cost worth it?
- **Cost**: A one-line use case adds another file, class, provider registration, test fixture, and navigation step. For a small team, this increases cognitive load, slows simple changes, and makes it harder to see where the actual behavior lives. It can also create the false impression that every class contains business logic when some are only pass-through wrappers.
- **Worth the cost when**: The use case gives a clear boundary for non-trivial business behavior, is reused, needs independent unit tests, or is likely to evolve soon. The extra structure is justified when it prevents business logic from leaking into notifiers/widgets; it is not justified merely to satisfy a fixed folder template.

### Q4: Which part of the AI proposal did you reject or simplify, and why?
- **Decision**: I rejected the idea of creating a use case for every CRUD operation, especially for the simple announcements read flow. I kept the repository interface in the domain and the concrete implementation in data, but wired the announcements repository directly to a Riverpod `FutureProvider`.
- **Why**: This preserves dependency inversion and testability while avoiding an extra pass-through class. I kept use cases where they express real application behavior, such as authentication orchestration and note operations that may later include synchronization or dirty-state handling. This is a pragmatic compromise: strict separation is applied where it protects business rules, while simple data retrieval remains readable and inexpensive to maintain.