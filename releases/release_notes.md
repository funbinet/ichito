# Release Notes - v5.5.1

## New Features
- **Font Management System**: Added 5 new distinct font styles (Roboto, Open Sans, Lato, Montserrat, Poppins) with instant global application across the app.
- **Font Scaling Overhaul**: Replaced the inconsistent slider with 6 distinct proportional font size states that correctly scale text across all components.
- **Notification Audit Trail**: Converted notifications into a permanent, undeletable system audit log backed by a SQLite database. Added search, filtering by module type, and full pagination support for the audit history.
- **Standardized Image Handling**: Updated image cropping tools to force square images across all customer, fabric, and garment views, while strictly enforcing circular avatars only on the dashboard.
- **Viewing Modes Improved**: Clicking on a client's avatar in view mode now opens a full-screen preview instead of the camera upload dialog.

## Bug Fixes
- Fixed bug where increasing font size only worked in the settings screen and failed to grow text elsewhere.
- Fixed an issue where client listing grids and cards were showing blank avatars instead of the client's uploaded images.
- Removed confusing camera overlays from view-only client detail screens.

## Technical Improvements
- Migrated hardcoded fixed `fontSize` variables across the codebase to properly use `theme.fontSize` proportional scaling.
- Bumped database schema to Version 4 to support permanent audit trail logs with comprehensive CRUD (`Created`, `Updated`, `Deleted`, `System`) and entity tracking.
- Optimized and separated the local push notification service from the persistent SQLite notification storage.

## Build Artifacts
- **Platform**: Android ARM64
- **Version**: 5.5.1
