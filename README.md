# Tahfidz Quran — Frontend

Flutter/Dart mobile client for the Tahfidz Quran system, built against the
[software specification](../software-requirment.md) in the main project
repository. Talks to the [backend API](https://github.com/yswijaya0106/tahfidzul-quran-backend).

## Stack

- Flutter (Material 3), feature-first clean architecture
- **State management:** flutter_riverpod
- **Routing:** go_router, with redirect-based auth guarding
- **HTTP:** dio, wrapped in `core/network/ApiClient` (auto access-token
  injection, single-flight refresh-on-401, error normalization)
- **Secure storage:** flutter_secure_storage for access/refresh tokens

## Getting started

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

`API_BASE_URL` defaults to `http://localhost:3000/api/v1` (the backend's
local dev server) when omitted.

## Architecture

```
lib/
  core/         network client, secure storage, theme, routing, shared
                error/pagination/async-state widgets
  features/
    auth/            login, session restore, logout / logout-all
    quran/           surah reference data (fetched from the API, never
                     duplicated client-side per CLAUDE.md)
    locations/       location selector + location context
    students/        list, detail, create
    assessments/     create (Quran-backed range picker) + history
    activities/       list, create (admin)
    dashboard/       location dashboard
    users/           admin user list + deactivate
    settings/        session management
```

Each feature follows `presentation -> application -> domain -> data`.
Widgets never call `dio` or storage directly — they go through
`application/*_providers.dart`, which wire `data/*_repository.dart`
implementations built on `core/network/ApiClient`.

## Every remote screen implements

Loading, empty, error (with retry), offline, and unauthorized states via
`core/widgets/AsyncValueView`, per CLAUDE.md's Flutter conventions.

## Photo uploads

The activity form supports picking multiple photos, each one:

1. Compressed client-side to ~500KB / max 1280px longest edge
   (`core/media/image_compressor.dart`, pure Dart via the `image` package —
   no native platform config needed), before any network call.
2. Uploaded with the presign -> direct PUT -> complete flow from the
   backend's Postman collection (`features/files/data/file_repository.dart`),
   with a per-photo progress indicator.
3. Attached to the activity as `{objectKey, mimeType, sizeBytes, caption,
   displayOrder}` on create.

Bytes go straight from the device to the storage provider via the
presigned URL — never through base64, and never through our own backend
process — matching CLAUDE.md's "never binary files in database rows" and
the spec's private/expiring-URL requirement.

## Known scope limitations in this build

- Student document photos (profile/ID card/graduation certificate) don't
  use the upload flow yet — only activity photos do so far.
- The admin user-management screen covers list + deactivate; create and
  location-assignment forms are a follow-up increment.
- No offline cache/persistence layer yet beyond Riverpod's in-memory
  provider state — `pull-to-refresh` and retry are wired, but there is no
  local database for true offline reads.
- `flutter build apk`/`ipa` release signing is not configured; CI runs a
  debug build to catch compile regressions.
