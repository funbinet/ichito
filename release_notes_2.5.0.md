# ICHITO v2.5.0 Release Notes

## Major Features & Improvements

### 1. Persistent Business Profile
- The business profile is now securely backed by a SQLite database instead of local cache.
- Added a new Profile screen accessible from the home screen avatar for easy management of business details.
- Support for selecting, cropping, and saving a business profile photo directly into the database.
- Added "Owner Name" field to the business profile.

### 2. Smart Notification System
- Added local push notifications for order due dates.
- Get automatically notified when an order is due today, or becomes overdue.
- New dedicated Notifications Screen to view and manage your alert history.
- Dynamic notification badge on the home screen showing your unread alert count.

### 3. Redesigned Navigation Experience
- Replaced the stacking radial menu with a clean, concentric arc layout.
- The navigation menu is now persistent across all major screens in the app.
- Added quick access to Profile and Notifications directly from the navigation menu.

### 4. Home Screen Enhancements
- Fixed stat cards text cut-off on smaller devices.
- Added themed accent outlines to all cards and buttons for a cohesive, premium look.
- Introduced a new "Upcoming Deadlines" scrollable section to track orders due within the next 7 days.

## Technical Details
- Migrated data layer to fully utilize SQLite for structured relational data.
- Upgraded target Android API levels and added necessary permissions for local push notifications.
