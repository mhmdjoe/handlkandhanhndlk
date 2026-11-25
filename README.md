# HNDLK W HNHNDLK (هندلك وهنهندلك)

An Egypt tourism discovery and trip-planning app built with Flutter, fully bilingual (English / Egyptian Arabic) with complete right-to-left support.

**Live web demo:** https://mhmdjoe.github.io/handlkandhanhndlk/ (runs in the browser, no install needed)

> "You choose the experience. We plan the journey."
> "أنت اختار التجربة، وإحنا نهندلك الرحلة."

## What it does

The app has two halves:

- **HNDLK (هندلك - "we show you")** - browse a curated database of Egyptian destinations: Greater Cairo, Alexandria and the North Coast, Luxor and Aswan, the Red Sea, South Sinai, Siwa Oasis, and Fayoum. Each attraction carries entrance fees in EGP/USD/EUR/GBP, operating hours, estimated visit duration, accessibility notes, and references to official sources (`mota.gov.eg`, `egymonuments.gov.eg`).
- **HNHNDLK (هنهندلك - "we plan it for you")** - build a multi-day trip: add attractions to specific days and time slots, attach a hotel by budget tier (Budget / Moderate / Luxury / Eco Lodge), and see whole-trip budget totals (activities + transport + hotel) update live, on a timeline or a map of Egypt.

### Trip planner details

- **Add-to-trip modal** - tap (+) on any attraction, pick the day and a time window (09:00, 11:30, 14:00, 16:30, 19:00), and jump straight into the trip timeline.
- **Rule-based itinerary engine** - schedules selected attractions across trip days and flags timing conflicts.
- **Experimental AI assistant** - a chat interface that turns a free-text request ("3 days in Cairo with history and local food under $150") into a suggested itinerary. It tries, in order: a local Python backend used during development, a direct call to the Gemini API (requires your own API key), and an offline keyword-matching fallback. This is an API integration demo, not a trained model.
- **Whole-trip and day-by-day views** with trip pins on an interactive map.

### Design and localization

- Glassmorphic floating bottom navigation (`BackdropFilter` blur), Material 3 "Nile Teal / Terracotta / Gold" theme.
- Instant English <-> Arabic switching with full RTL layout mirroring (`flutter_localizations`, `intl`).
- Responsive across mobile, tablet, and web.

## Tech stack

| Component | Technology |
| :--- | :--- |
| Framework | Flutter (Dart 3.x), Android / iOS / Web |
| State management | Provider |
| Persistence | `shared_preferences` (localStorage on web) |
| Localization | `flutter_localizations`, `intl` (full RTL/LTR) |
| AI integration | Gemini API (HTTP) + offline fallback |
| Architecture | Layered: `models/`, `data/`, `services/`, `providers/`, `views/`, `widgets/` |

## Project structure

```text
lib/
├── data/tourism_database.dart       # Bundled Egyptian tourism dataset
├── l10n/app_localizations.dart      # EN/AR string dictionary
├── models/models.dart               # Destination, Attraction, Hotel, Transport, Trip
├── providers/app_provider.dart      # Locale, currency, trips, favorites
├── services/
│   ├── ai_assistant_service.dart    # Gemini integration + offline fallback
│   ├── auth_service.dart            # Demo-mode sign-in (see Status)
│   ├── itinerary_engine.dart        # Scheduling + conflict detection
│   └── storage_service.dart         # Local persistence
├── theme/app_theme.dart
├── views/                           # explore, planner, hotels, map, trips, profile, onboarding, auth, admin
└── widgets/                         # add-to-trip modal, glassmorphic container, image fallback
```

## Run it locally

```bash
git clone https://github.com/mhmdjoe/handlkandhanhndlk.git
cd handlkandhanhndlk
flutter pub get
flutter run            # or: flutter run -d chrome
```

Web build:

```bash
flutter build web --wasm --release
```

## Status

Active portfolio project, not a released product. Tourism data is a bundled seed dataset (prices and hours go stale), sign-in is demo-mode (simulated, no backend accounts), and the AI assistant needs your own Gemini API key to answer live. The `docs/` folder holds the GitHub Pages web build.

## License

MIT
