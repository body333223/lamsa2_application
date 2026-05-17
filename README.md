# لمسة — Lamsa

تطبيق حجز خدمات التجميل والعناية الشخصية.

## المتطلبات

- Flutter SDK 3.x+
- Dart 3.x+
- Firebase project configured

## التشغيل

```bash
flutter pub get
flutter run
```

## البناء

```bash
flutter build apk --release
flutter build ios --release
```

## البنية

```
lib/
├── core/           # Theme, widgets, localization
├── features/       # Feature modules (home, bookings, profile, etc.)
├── models/         # Data models
└── services/       # Firebase, auth, connectivity services
```
