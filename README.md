# Room Access Request System

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

   Or override Supabase values at runtime:
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```

A sample file is included at `.env.example`.


## Supabase setup (required)

Run these SQL files in Supabase SQL Editor:

1. `supabase/schema.sql` (creates all required tables)
2. `supabase/seed.sql` (adds sample role/profile/member data after Auth users are created)

Then create Auth users (email/password) from Supabase Dashboard or Admin API for:
- student1, student2
- admin1, admin2
- guard
- techadmin

Important role values for `public.profiles.role`:
- `student`
- `admin`
- `guard`
- `tech_admin` (must include underscore)

Quick fix if Tech Admin role insert/update fails:
```sql
update public.profiles
set role = 'tech_admin'
where email = 'techadmin@example.com';
```
