# QuickTrack

QuickTrack is a hospital equipment tracking system with a Flutter QR scanner,
a Supabase backend, and a Next.js operations dashboard.

The scanner does not require a user account. It validates an equipment QR code,
shows the equipment name without exposing its current ward, prioritises recently
used destination wards, and moves equipment as soon as a ward card is tapped.
The atomic `move_equipment` database function updates the current ward and
appends movement history in one transaction. The dashboard requires
authentication and receives live equipment-location updates through Supabase
Realtime.

## Prerequisites

- Flutter with Dart 3.9 or newer
- A Supabase project with all migrations applied
- Android or iOS device with a camera

Install dependencies before the first run:

```sh
flutter pub get
```

The iOS project already includes this camera permission description in
`ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>QuickTrack uses the camera to scan equipment QR codes.</string>
```

Run with the Supabase project URL and publishable key (the legacy anon key also
works as the publishable key value):

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Do not put a Supabase service-role key in a mobile application.
