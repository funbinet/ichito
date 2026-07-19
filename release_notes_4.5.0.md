# ICHITO v4.5.0 Release Notes

## Complete System Overhaul

This release brings a comprehensive system overhaul addressing critical functionality gaps and UI/UX inconsistencies across the entire application.

### Key Highlights
- **Onboarding & Orders Wizard**: Stripped down the onboarding screen and moved Garment, Fabric, and Measurement setup logic into the Order Wizard for a much smoother workflow. Implemented "+ Add" popups directly within the wizard for instant database saving.
- **Client/Order Linking**: Ensured that relationships between Clients and Orders are fully functional and accurately linked in the local SQLite database.
- **Sheng Translation Expansion**: Overhauled translation strings (e.g., "Mteja" to "Wateja", "Profili", etc.) and ensured that language switching takes effect instantly without needing an app restart.
- **Grid/List Views & Organization**: Standardized the toggle between grid and list views for Fabrics, Designs, Clients, Orders, and Notes. Added real search, sorting, and filtering functionality across all main entities.
- **Real Stats Dashboard**: The Dashboard now pulls live data directly from the SQLite database to display Active Orders, Revenue, Active Clients, and Top Garments.
- **Theme & Security Polish**: Reduced corner style complexity (now only 'Rounded' or 'Sharp'), properly linked UI components to ThemeProvider, and integrated full biometric/PIN auto-lock security logic seamlessly.

### Bug Fixes
- Fixed "Coming Soon" placeholders for detail pages by properly mapping routes in RouteGenerator.
- Ensured the dynamic chart data reflects actual historical metrics accurately.
