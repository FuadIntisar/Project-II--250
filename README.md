# Attendance App (Flutter)

A simple attendance app:
- **Sir**: logs in, creates courses, adds students, marks present/absent, views history.
- **Students**: pick their course + roll number, see their own attendance — read only.

Data is stored in **Firebase Firestore**, so it's shared live between sir's phone and every
student's phone.

## 1. Copy this into your Flutter project

If you already created a project with `flutter create attendance_app`, just copy:
- `lib/` (overwrite the existing lib folder)
- `pubspec.yaml` (overwrite, or merge the `dependencies:` section)

into your project folder.

## 2. Install dependencies

```
flutter pub get
```

## 3. Connect Firebase (required — the app will not run without this)

1. Go to https://console.firebase.google.com and create a new project (free tier is enough).
2. Install the FlutterFire CLI (one time):
   ```
   dart pub global activate flutterfire_cli
   ```
3. From inside this project folder, run:
   ```
   flutterfire configure
   ```
   Follow the prompts, select your Firebase project, and select the platforms you need
   (Android / iOS). This will **overwrite** the placeholder `lib/firebase_options.dart`
   with your real project's config.
4. In the Firebase console, go to **Build > Firestore Database > Create database**,
   and start it in **test mode** for now (so reads/writes work while you're developing).
   Before sharing the app with real students, tighten the rules — see `firestore.rules.example`.

## 4. Run it

Connect a phone (USB debugging on) or start an emulator, then:

```
flutter run
```

## 5. Build an APK to share

```
flutter build apk --release
```

The file will appear at:
```
build/app/outputs/flutter-apk/app-release.apk
```
Share that file directly (WhatsApp, Drive, etc.) — no Play Store needed for testing.


