# ERISH — Luxury E-Commerce App (Flutter & Firebase)

A modern, responsive, high-fashion Flutter application upgraded from the ERISH luxury landing page design, equipped with Firebase Cloud Firestore, Authentication, and dynamic shopping cart architecture.

---

## 📁 Project Architecture

```
erish_app/
├── assets/
│   └── images/               # All high-res photography (hero, banner diptych, moods, products, logo)
├── lib/
│   ├── main.dart             # App entry, CustomScrollView, slivers, key scrolling
│   ├── firebase_options.dart # Firebase platform configuration boilerplate
│   ├── constants/
│   │   └── app_theme.dart    # Palette (Ivory, Ink, Pink, Gold), Typography (Cormorant Garamond & Jost)
│   ├── models/
│   │   ├── product.dart      # Firestore-ready Product model + fallback data
│   │   ├── cart_item.dart    # Cart item model with sizes, quantities & prices
│   │   └── mood_edit.dart    # Collection mood card definitions
│   ├── services/
│   │   ├── firebase_service.dart # Realtime Firestore streams, order placement, newsletter subscriptions
│   │   └── cart_provider.dart    # Reactive state management for shopping bag
│   └── widgets/
│       ├── announcement_bar.dart   # Animated ticker marquee
│       ├── nav_header.dart         # Sticky responsive header with live bag counter
│       ├── hero_section.dart       # Full-bleed photography hero with dual dark gradient
│       ├── diptych_banner.dart     # "A World of Prints" 2-panel photo showcase
│       ├── product_grid.dart       # "New Arrivals" cards with hover zoom & size selection
│       ├── editorial_experience.dart # "The Wardrobe Experience" 3 numbered features
│       ├── mood_section.dart       # "Shop by Mood" 3 editorial mood cards
│       ├── story_section.dart      # "Born from wanderlust" brand narrative
│       ├── promo_banner.dart       # "Your next favourite is one scroll away" banner
│       ├── instagram_section.dart  # Direct link & 6-tile grid for @label_erish
│       ├── newsletter_section.dart # Live Firestore email subscription form
│       ├── footer_section.dart     # Policy modals, copyright, brand links
│       ├── cart_drawer.dart        # Slide-out cart drawer with checkout
│       ├── info_modal.dart         # Shipping, Returns, FAQ, Privacy, Terms modals
│       └── search_dialog.dart      # Real-time keyword product search
```

---

## 🚀 How to Run the App

### 1. Run on Chrome (Web)
```bash
cd erish_app
flutter run -d chrome
```

### 2. Run on Android Device / Emulator
```bash
cd erish_app
flutter run -d android
```

### 3. Run on Windows / Desktop
```bash
cd erish_app
flutter run -d windows
```

### 4. Build for Production Web
```bash
cd erish_app
flutter build web
```

---

## 🔥 Linking Your Live Firebase Project

The app is built with **zero-friction local mock fallback**: it runs immediately out-of-the-box even before you link your Firebase credentials.

When you're ready to connect your production Firebase project:
1. Make sure you are logged in:
   ```bash
   firebase login
   ```
2. Activate and run `flutterfire`:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
3. Select your Firebase project. It will automatically update `lib/firebase_options.dart` with your live project keys for Web, Android, and iOS!
