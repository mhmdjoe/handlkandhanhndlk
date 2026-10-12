# HNDLK W HNHNDLK (هندلك وهنهندلك)

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web-00A896?style=for-the-badge" alt="Platforms" />
  <img src="https://img.shields.io/badge/Language-English%20%7C%20العربية-D4AF37?style=for-the-badge" alt="Localizations" />
  <img src="https://img.shields.io/badge/Design-Apple%20HIG%20Glassmorphism-C85A32?style=for-the-badge" alt="Design" />
</p>

<p align="center">
  <a href="https://mhmdjoe.github.io/handlkandhanhndlk/">
    <img src="https://img.shields.io/badge/🌐%20Live%20Web%20App-Experience%20Instantly%20in%20Browser-00A896?style=for-the-badge&logo=googlechrome&logoColor=white" alt="Live Web App" />
  </a>
</p>

<h3 align="center">
  👉 🌐 <a href="https://mhmdjoe.github.io/handlkandhanhndlk/">Experience Platform Live in Web Browser (Explore instantly in your web browser!)</a>
</h3>

> **"You choose the experience. We plan the journey."**
> **"أنت اختار التجربة، وإحنا نهندلك الرحلة."**

**HNDLK W HNHNDLK** is a market-ready Egyptian tourism discovery and intelligent trip-planning platform built with Flutter. It combines rich, verified Egyptian destination data with a conversational AI itinerary engine, hotel accommodation budget matching, and an Apple HIG-compliant glassmorphic visual experience.

---

## 🌟 The Dual Promise Identity

- **HNDLK (هندلك - "We show you what you can do"):** Discover every verified attraction, ancient monument, coastal resort, desert oasis, hotel, and transport mode across Egypt.
- **HNHNDLK (هنهندلك - "We plan and arrange everything for you"):** AI-powered intelligent trip planner that automatically crafts multi-day schedules, optimizes visit timings, calculates total budget breakdowns, and detects operating hour conflicts.

---

## ✨ Key Features

### 🏛️ 1. Comprehensive Egyptian Tourism Database
- **Geographic Coverage:** Greater Cairo, Alexandria & North Coast, Upper Egypt (Luxor & Aswan), Red Sea (Hurghada), South Sinai (Sharm El Sheikh, Dahab, St. Catherine), Western Desert (Siwa Oasis), and Fayoum.
- **Verified Source Badges:** Entrance fees in multiple currencies (**EGP**, **USD**, **EUR**, **GBP**), operating hours, estimated visit durations, accessibility notes, and official government data source references (`mota.gov.eg`, `egymonuments.gov.eg`).

### 🤖 2. Conversational AI Travel Assistant ("HNHNDLK")
- Enter natural language trip requests (e.g., *"3 days in Cairo with history & local food under $150"*).
- Generates structured day-by-day itineraries complete with entrance fee totals, transport legs, and operating hour verifications.

### ➕ 3. Interactive "Add to Trip" Popup Modal
- Tapping **(+) Add to Trip** on any attraction opens a clean bottom sheet modal.
- Pick target trip days (**Day 1, Day 2, Day 3...**) and visit time windows (`09:00`, `11:30`, `14:00`, `16:30`, `19:00`).
- Features a direct **"Open Trip"** action button to jump straight into the interactive timeline.

### 🏨 4. Hotel Accommodation & Budget Selector
- Filter hotels by budget tier: **Budget**, **Moderate**, **Luxury**, or **Eco Lodge**.
- Select and attach hotels (e.g. *Marriott Mena House Cairo*, *Steigenberger Cecil Alex*, *Sofitel Legend Old Cataract Aswan*, *Adrere Amellal Siwa*) directly to whole trips.
- Dynamically recalculates whole-trip budget totals (**Activities + Transport + Hotel Stay**).

### 🗺️ 5. Whole Trip Master View & Interactive Map
- Toggle between **Whole Trip Master Plan** and **Day-by-Day** schedule views.
- View entire trip pins projected across Egypt on an interactive map.

### 🎨 6. Apple HIG Glassmorphism & Floating Navigation
- Floating glassmorphic bottom navigation bar with `BackdropFilter` backdrop blur (`ImageFilter.blur(sigmaX: 20, sigmaY: 20)`), glowing active pills, and smooth tab animations.
- Fully responsive across mobile, tablet, and web browsers.

### 🌐 7. Full Bilingual & Right-to-Left (RTL) Support
- Instant dynamic language switching between **English** and **Egyptian Arabic**.
- Full RTL layout adjustments for Arabic text, icons, and navigation directions.

---

## 🛠️ Technology Stack

| Component | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev/) (Dart 3.x) |
| **State Management** | [Provider](https://pub.dev/packages/provider) |
| **Local Persistence** | [shared_preferences](https://pub.dev/packages/shared_preferences) (`localStorage` on Web) |
| **Localizations** | `flutter_localizations` & `intl` (Full RTL / LTR) |
| **Design System** | Material 3 + Apple HIG Material Glassmorphism |
| **Architecture** | Clean Layered Architecture (`models/`, `data/`, `services/`, `providers/`, `views/`, `widgets/`) |

---

## 📁 Project Structure

```
lib/
├── data/
│   └── tourism_database.dart          # Authentic Egyptian tourism dataset & seed records
├── l10n/
│   └── app_localizations.dart         # Bilingual English & Egyptian Arabic dictionary
├── models/
│   └── models.dart                    # Destination, Attraction, Hotel, Transport, Trip models
├── providers/
│   └── app_provider.dart              # Core reactive state provider (Locale, Currency, Trips, Favorites)
├── services/
│   ├── ai_assistant_service.dart      # Conversational AI trip generator engine
│   ├── auth_service.dart              # User sign-in, registration & guest mode
│   ├── itinerary_engine.dart          # Schedule solver & conflict detector
│   └── storage_service.dart           # Persistent local storage manager
├── theme/
│   └── app_theme.dart                 # Nile Teal, Terracotta & Gold Material 3 color system
├── views/
│   ├── admin/                         # Admin dataset health dashboard
│   ├── auth/                          # Login & registration views
│   ├── explore/                       # HNDLK discovery, attraction & destination details
│   ├── home/                          # Main discovery home portal
│   ├── hotels/                        # Hotel search & reservation view
│   ├── map/                           # Interactive map view
│   ├── onboarding/                    # Welcome screen & travel preference quiz
│   ├── planner/                       # HNHNDLK AI Assistant & whole trip timeline
│   ├── profile/                       # User profile, settings & favorites
│   ├── transport/                     # Transport route planner view
│   └── trips/                         # My Trips whole trip master dashboard
├── widgets/
│   ├── add_to_trip_modal.dart         # Interactive popup modal for adding places to trip
│   ├── glassmorphic_container.dart    # Apple HIG BackdropFilter glassmorphism container
│   └── network_image_with_fallback.dart # Network image with shimmering & fallback placeholders
└── main.dart                          # App entry point with MultiProvider setup
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19 or higher)
- [Dart SDK](https://dart.dev/get-started/sdk) (v3.x)

### Local Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/mhmdjoe/handlkandhanhndlk.git
   cd handlkandhanhndlk
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run static analysis & tests:**
   ```bash
   flutter analyze
   flutter test
   ```

4. **Launch the application:**
   ```bash
   flutter run
   ```

---

## 🌐 Web Deployment

To run or build the platform for Web:

```bash
# Run locally on Chrome
flutter run -d chrome

# Build production WASM Web release
flutter build web --wasm --release
```

The output in `build/web/` can be deployed directly to Firebase Hosting, Vercel, Netlify, or GitHub Pages.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for details.

Developed with ❤️ for Egypt's tourism technology landscape.
