# Supabase Schema

This folder contains the canonical Supabase/Postgres schema for FoulAndFortune.

## Apply the schema

Option 1: Supabase SQL Editor
1) Open your Supabase project.
2) Go to SQL Editor.
3) Paste the contents of `supabase/schema.sql` and run.

Option 2: psql
```
psql "$DATABASE_URL" -f supabase/schema.sql
```

Notes:
- The script enables RLS and creates policies. Run it with a role that can create extensions, functions, triggers, and RLS policies (service role).
- The schema expects Supabase Auth (`auth.users`) to exist.
