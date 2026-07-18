# ICHITO v2.0.0 Release

Welcome to **ICHITO v2.0.0**, the major update bringing massive customization and control over your tailoring shop!

## 🚀 Major Features & Enhancements
- **Dynamic Measurement Schema**: You can now define your own measurement fields globally during setup (e.g. Chest, Waist, Hips, Inseam). They automatically map to your customers and garments.
- **Extensive Onboarding**: We completely revamped the setup flow into an 8-page experience. You can now define your global Garment Catalog and Fabric Inventory right when setting up the app.
- **Advanced Dashboard & Analytics**: Added `AnalyticsScreen` utilizing beautiful interactive charts for revenue and order tracking over time.
- **Improved Settings & Customization**: Customize UI themes and accent colors on the fly. You can also Factory Reset your entire shop securely.
- **Brand Identity**: The app now proudly uses the updated **ICHITO** white logo with transparent backgrounds, capitalizing correctly across all interfaces.
- **Dynamic Routing Fixes**: We have eliminated the "ERROR: router not found" issue. Unimplemented features (like Fabrics/Designs standalone screens) now display a clean "Coming Soon" screen instead of erroring out.

## 🛠 Fixes & Polishing
- Replaced the default Flutter app icon with the white-transparent ICHITO logo.
- Capitalized the app name to **ICHITO** globally, including Android Home screen.
- Enhanced `RadialMenu` navigation robustness to never fail on unregistered routes.
- Adjusted SQLite database constraints for dynamic Garment and Fabric setups.
- General UI cleanup, spacing, and micro-animations for a premium feel.

Thank you for choosing ICHITO! Enjoy managing your tailoring business offline.
