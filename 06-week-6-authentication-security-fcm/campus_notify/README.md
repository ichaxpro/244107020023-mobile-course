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
