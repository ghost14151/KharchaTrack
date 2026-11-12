# KharchaTrack

KharchaTrack is a free, offline-first Flutter app for tracking income, expenses and monthly budgets. This build contains no advertising SDK or ad placements.

## Features

- Add, edit, search and delete transactions
- Income, expenses and balance overview
- Monthly spending budget
- CSV export and JSON backup/restore
- PIN lock and optional device biometric unlock
- Daily local reminders
- Currency display options (INR, USD, EUR, GBP, AED, CAD and AUD)
- Light and dark themes

## Important notes

- Currency selection changes the displayed currency symbol; it does **not** convert stored amounts using exchange rates.
- This repository currently uses Google's official **test** AdMob app, banner and interstitial IDs. The full-screen test interstitial is attempted at most once every 6 hours; it is closeable and never blocks app use when unavailable. Test ads do not generate revenue. Do not publish with test IDs expecting earnings.
- The current GitHub Actions release build uses the repository's debug signing configuration. A production distribution build needs a properly protected release keystore and signing secrets.

## Privacy

See [PRIVACY_POLICY.md](PRIVACY_POLICY.md).

## Build

GitHub Actions builds the Android release APK. Open the Actions tab and download the KharchaTrack-release artifact from a successful run.
