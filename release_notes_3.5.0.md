# ICHITO v3.5.0 Release Notes

Welcome to ICHITO v3.5.0! This release brings significant UI refinements, workflow completions, and bug fixes to make the user experience even smoother.

## ✨ What's New

- **Radial Menu Refinements**: Completely redesigned the bottom navigation radial menu to use a responsive grid wrap. All items are now evenly spaced and fully readable, resolving issues with truncated text in the previous row-based layout.
- **Context-Aware Navigation**: The radial menu is now hidden on detail screens, forms, and editors, ensuring it doesn't obstruct content where it isn't needed.
- **End-to-End Order Wizard**: Connected the final steps of the Order Wizard! The `Create Order` button now directly integrates with the database, saves the initial deposit correctly, and seamlessly navigates to the detailed view of the newly created order.
- **PDF & CSV Statistics Export**: Fully implemented the export buttons on both the Dashboard and Analytics screens. You can now generate actual PDF reports and CSV files of your business statistics, complete with native share sheet integration to instantly send or save them.

## 🐛 Bug Fixes & Improvements

- **Database Safety**: Addressed SQLite `close()` method duplication warnings.
- **File Picker Stability**: Migrated `FilePicker.platform` calls to the newer, stable `FilePicker.pickFiles` static API to resolve build errors and prevent crashes during backup restoration.
- **Image Rendering Consistency**: Replaced buggy `FileImage` renderings with robust base64 `MemoryImage` processing across all customer components, aligning with the database's string-based image storage.
- **Dependency Cleanups**: Removed unused `dart:io` imports and fixed missing `uuid` and component imports across various dialogs and screens.
- **Share API Modernization**: Upgraded deprecated `Share.shareXFiles` implementations to the latest `SharePlus` API parameters for database backups.

*Thank you for using ICHITO! We are constantly working to improve your workspace.*
