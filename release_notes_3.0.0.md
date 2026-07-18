# ICHITO Release v3.0.0

Welcome to the largest update to ICHITO yet! Version 3.0.0 brings a complete redesign of the user interface, brand new security features, and powerful new modules for tracking your work.

## What's New

### 🎨 Complete UI/UX Overhaul
- **New Navigation Grid**: Replaced the old radial menu with a fast, intuitive 2×6 floating grid panel.
- **Dynamic Action Buttons**: Introduced floating, rectangular "Page Action Buttons" across all library screens for quick additions.
- **Theme & Appearance Settings**: Fully revamped settings with a new color picker supporting custom accent colors and system theme matching.

### 🔒 Enterprise-Grade Security
- **App Lock**: Secure your data with a 4-digit PIN or custom alphanumeric password.
- **Biometric Unlock**: Use your fingerprint or face ID to quickly unlock the app.
- **Auth-Gated Deletions**: Important deletions (Customers, Orders, Garments, Fabrics, Designs, Notes) now require PIN/biometric authentication to prevent accidental data loss.

### 👗 New Libraries
- **Designs Library**: Build a catalog of your clothing designs. Track styles, seasons, complexity, and reference images.
- **Fabrics Library**: Manage your fabric inventory. Track material types, colors, stock levels (in meters/yards), and supplier information.
- **Garments Library Update**: Fully integrated Garments into the new navigation flow and component system.

### 📝 Advanced Note Taking
- **Three Custom Editors**: 
  - **Normal Notes**: For general ideas and reminders.
  - **Church Notes**: Specialized editor for sermon notes, including Speaker and Bible Verses fields.
  - **Chama Notes**: Specialized editor for group savings meetings, featuring contribution tracking, date selection, and meeting minutes.

## Under the Hood
- Migrated data structures to support enhanced analytics (coming soon).
- Upgraded local storage engine and encrypted sensitive settings with `flutter_secure_storage`.
- Expanded localization support to over 150+ translation keys across the app.

Thank you for using ICHITO!
