# ICHITO v6.0.0 Release Notes

Welcome to ICHITO v6.0.0, a major system upgrade focusing on improved security, robust data backup, and a premium settings experience!

## 🚀 Key Features & Upgrades

### 🎨 Appearance & Themes
- **Persistent Fonts**: Font selection and global font size now persist correctly after app restarts.
- **True Multi-Color Gradients**: Complete reimplementation of the gradient system. Gradients now feature true multi-color transitions, and they are mutually exclusive with solid accent colors (only one can be active at a time).

### 🌍 Language & Format
- **Streamlined UI**: Completely redesigned the language section using premium cards.
- **Focused Languages**: Removed unnecessary measurement units, currency, and date formats. The system now defaults to English and Sheng (Kenyan slang) with instant translation across the app.

### 🔒 Enhanced Security
- **Dual Lock Support**: Choose between a secure PIN or an alphanumeric Password to lock the app.
- **Biometric Fallback**: Seamless integration with your device's fingerprint or face unlock.
- **Strict Authentication**: Changing your PIN or Password now requires verifying your current authentication first.

### 📏 Measurement Types
- **Global Synchronization**: Removed mock data. All measurement schemas now sync globally across the application.
- **Custom Metrics**: Easily add, edit, or delete custom measurement metrics right from the settings.

### 💾 Backup & Restore
- **Complete ZIP Backups**: A brand new backup system that packages your SQLite database (`ichito.db`) and all locally saved images (`app_data/images`) into an encrypted zip file.
- **Seamless Restore**: Restore your entire database and images in one click by selecting a `.zip` backup file.

### ℹ️ Help & About
- **Direct Support**: Contact support instantly via WhatsApp from the Help screen.
- **Open Source Links**: The About screen now includes the official ICHITO logo, version info, and direct links to our GitHub and Codeberg repositories.

## 🛠 Fixes & Improvements
- Addressed all known critical issues across the application's settings and state management.
- Improved dependency handling and path routing.
- Under-the-hood performance optimizations for faster load times.
