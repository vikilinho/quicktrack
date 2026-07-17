# WardFind dashboard

Next.js App Router dashboard for live hospital equipment tracking.

## Setup

```sh
cp .env.example .env.local
npm install
npm run dev
```

Set the public Supabase project URL and publishable key in `.env.local`. Create
dashboard users in Supabase Authentication; unauthenticated visitors only see
the sign-in screen, and database RLS restricts dashboard data to authenticated
sessions.

Create the initial dashboard account under **Authentication → Users** in the
Supabase dashboard. The web application intentionally has no public sign-up
flow.

Apply the migration in `../supabase/migrations` to publish `equipments` and
`wards` through Supabase Realtime.
