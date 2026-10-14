# Servo

A Flutter service marketplace with separate customer and provider experiences.

## Features

- Registration, sign-in, session restoration and role-based navigation.
- Customer service browsing, categories, search, filters and bookings.
- Provider dashboard, service management and booking status actions.
- Profiles, profile photos, password changes and notification preferences.
- Booking conversations with text and image messages and manual refresh.
- In-app notifications, FAQs and support contact requests.

## Run locally

Install Flutter with Dart compatible with `^3.12.2`, then run:

```sh
flutter pub get
flutter run
```

The default backend is `https://services.alshalabiapps.com/api/v1/`.
To use a different compatible backend (include the trailing slash):

```sh
flutter run --dart-define=API_BASE_URL=https://your-api.example/api/v1/
```

[API documentation](https://services.alshalabiapps.com/docs/api#/)

## Project layout

```text
lib/
  core/                       # Theme, assets, network, shared widgets and shells
  feature/
    auth/                     # Authentication and session routing
    user_account/             # Customer home, bookings, messages and profile
    company_account/          # Provider services, orders, messages and profile
test/                         # Unit and widget tests, API fixtures
```

The app uses Flutter Bloc for authentication and customer navigation/filtering,
controllers for provider services and chat, Dio for HTTP, and SharedPreferences
for local session/profile preferences. This repository does not include the
backend implementation.

## Check changes

```sh
flutter analyze
flutter test
flutter build apk --debug
```

API tests use mock responses. Passing tests does not confirm live backend
permissions or every response shape. Exercise service creation, booking and
messaging with customer and provider accounts before a release.

## Current limitations

- Chat refresh is manual; voice recording and calls are not implemented.
- Notifications are available inside the app. Background push notifications and
  Google sign-in are not configured; no Firebase project is bundled.
- Booking times are customer requests, not server-confirmed availability.
- Profile specialization is stored locally per account where the API lacks an
  update field.
- Password reset requires a valid email/token from the backend reset link.
- Android uses `com.example.servo` and debug signing for release builds. Configure
  an application ID and private release signing before publishing to an app
  store. Platform release builds require their own validation.

## Repository hygiene

Keep `pubspec.lock` in version control. Build output, local SDK paths, IDE caches,
environment credentials and signing keys are ignored. Do not commit access
tokens or production account details. The API base URL is configuration, not a
secret.
