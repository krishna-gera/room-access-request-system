# Saptak Container Access App

Flutter app for managing container-room access requests with role-based flows:
- Student: create request, view approvals, show QR pass.
- Admin: review and approve requests.
- Guard: scan QR and validate time-window access.
- Tech Admin: placeholder dashboard.

## Setup

1. Install Flutter SDK.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Configure environment variables in `.env`:
   ```env
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-anon-key
   ```
4. Run app:
   ```bash
   flutter run
   ```

A sample file is included at `.env.example`.
