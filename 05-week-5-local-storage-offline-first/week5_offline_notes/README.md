# Local Storage & Offline First 📢

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
> *Flutter Offline Notes app: note CRUD + theme preference.
Compare SharedPreferences, Hive, sqflite (SQLite), and Drift
for these two needs. Requirements:
- Criteria: query complexity, relational needs, reactivity (streams),
  type-safety, boilerplate size, and testability.
- Give a final recommendation: which for preferences, which for notes,
  with reasons in one table.
- Show the table/box schema for 1000+ notes.
Explain the trade-off of each choice.*

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

### Q1: Why must the note list not be stored in SharedPreferences? What breaks if this rule is violated?

The note list should not be stored in `SharedPreferences` because it is intended for small key-value settings, such as `darkMode` or `forceOffline`, not structured collections that need filtering, sorting, updating, and transactions. Notes belong in SQLite because each note has fields such as an ID, title, body, timestamp, and dirty status. If the list were stored in `SharedPreferences`, the whole list would need to be serialized and rewritten for every change. This makes querying and partial updates inefficient, increases the risk of data corruption, and makes reliable synchronization harder.

### Q2: When is cache-first enough, and when do you need another strategy (e.g. network-first for real-time prices)?

Cache-first is enough when the application must remain useful offline and slightly old data is acceptable, such as personal notes or previously loaded reference content. The app can show the local data immediately and synchronize changes in the background. A network-first strategy is more appropriate when freshness is critical, such as stock prices, ticket availability, or a live delivery status. In those cases, stale cache data can mislead the user, so the app should try the network first and use the cache only as a fallback when the request fails.

### Q3: How does a dirty flag become a sync queue without blocking the UI?

When a note is created or edited, it is written to SQLite with `dirty = 1`. The UI reads the local database immediately, so the user does not have to wait for the server. The dirty count acts as a small sync queue: `countDirty()` reports how many records still need to be uploaded, and `syncNotes()` processes them asynchronously. After the server responds successfully, the records are marked with `dirty = 0`, and the badge changes back to zero. With `forceOffline` enabled, synchronization is skipped while the local notes and dirty badge remain available.

### Q4: Which part of the AI draft did you reject or fix, and why?

I rejected the unused `loadPostsCacheFirst()` draft because it referenced `Post`, `readCachedPosts()`, and `refreshPostsInBackground()` even though those types and functions did not exist in this notes project. Keeping it would make the project fail static analysis. I also replaced the default counter screen with a notes screen so the offline behavior, dirty badge, force-offline toggle, and sync result can be demonstrated directly. The final implementation keeps the useful SQLite and Riverpod ideas but adapts them to the actual project structure and verifies them with tests.
