-- FoulAndFortune Supabase schema (offline-first sync target)
-- Apply in the Supabase SQL editor or via psql.

begin;

create extension if not exists "pgcrypto";

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id)
  values (new.id)
  on conflict do nothing;
  return new;
end;
$$;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  label text,
  last_seen_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.players (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  device_id uuid,
  revision integer not null default 0,
  games_played integer not null default 0,
  games_won integer not null default 0,
  total_points integer not null default 0,
  total_innings integer not null default 0,
  total_fouls integer not null default 0,
  total_saves integer not null default 0,
  highest_run integer not null default 0
);

create table if not exists public.games (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  player1_id uuid references public.players(id) on delete set null,
  player2_id uuid references public.players(id) on delete set null,
  player1_name text not null,
  player2_name text not null,
  is_training_mode boolean not null default false,
  player1_score integer not null default 0,
  player2_score integer not null default 0,
  start_time timestamptz not null,
  end_time timestamptz,
  is_completed boolean not null default false,
  winner text,
  race_to_score integer not null,
  player1_innings integer not null default 0,
  player2_innings integer not null default 0,
  player1_highest_run integer not null default 0,
  player2_highest_run integer not null default 0,
  player1_fouls integer not null default 0,
  player2_fouls integer not null default 0,
  active_balls jsonb,
  player1_is_active boolean,
  snapshot jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  device_id uuid,
  revision integer not null default 0
);

create table if not exists public.achievements (
  user_id uuid not null references auth.users(id) on delete cascade,
  achievement_id text not null,
  unlocked_at timestamptz,
  unlocked_by jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  device_id uuid,
  revision integer not null default 0,
  primary key (user_id, achievement_id)
);

create table if not exists public.settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  three_foul_rule_enabled boolean not null default true,
  race_to_score integer not null default 100,
  player1_name text not null default '',
  player2_name text not null default '',
  is_training_mode boolean not null default false,
  is_league_game boolean not null default false,
  player1_handicap integer not null default 0,
  player2_handicap integer not null default 0,
  player1_handicap_multiplier double precision not null default 1.0,
  player2_handicap_multiplier double precision not null default 1.0,
  max_innings integer not null default 25,
  sound_enabled boolean not null default true,
  language_code text not null default 'de',
  is_dark_theme boolean not null default false,
  theme_id text not null default 'cyberpunk',
  has_seen_break_foul_rules boolean not null default false,
  has_shown2_foul_warning boolean not null default false,
  has_shown3_foul_warning boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  device_id uuid,
  revision integer not null default 0
);

create table if not exists public.sync_state (
  user_id uuid not null references auth.users(id) on delete cascade,
  device_id uuid not null,
  last_sync_at timestamptz,
  last_sync_token text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, device_id)
);

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

drop trigger if exists set_profiles_updated_at on public.profiles;
create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

drop trigger if exists set_devices_updated_at on public.devices;
create trigger set_devices_updated_at
  before update on public.devices
  for each row execute function public.set_updated_at();

drop trigger if exists set_players_updated_at on public.players;
create trigger set_players_updated_at
  before update on public.players
  for each row execute function public.set_updated_at();

drop trigger if exists set_games_updated_at on public.games;
create trigger set_games_updated_at
  before update on public.games
  for each row execute function public.set_updated_at();

drop trigger if exists set_achievements_updated_at on public.achievements;
create trigger set_achievements_updated_at
  before update on public.achievements
  for each row execute function public.set_updated_at();

drop trigger if exists set_settings_updated_at on public.settings;
create trigger set_settings_updated_at
  before update on public.settings
  for each row execute function public.set_updated_at();

drop trigger if exists set_sync_state_updated_at on public.sync_state;
create trigger set_sync_state_updated_at
  before update on public.sync_state
  for each row execute function public.set_updated_at();

create index if not exists devices_user_idx
  on public.devices (user_id);

create index if not exists players_user_idx
  on public.players (user_id);

create unique index if not exists players_user_name_key
  on public.players (user_id, lower(name));

create index if not exists games_user_start_time_idx
  on public.games (user_id, start_time desc);

create index if not exists games_user_completed_idx
  on public.games (user_id, is_completed, start_time desc);

create index if not exists achievements_user_idx
  on public.achievements (user_id);

create index if not exists sync_state_user_idx
  on public.sync_state (user_id);

alter table public.profiles enable row level security;
alter table public.devices enable row level security;
alter table public.players enable row level security;
alter table public.games enable row level security;
alter table public.achievements enable row level security;
alter table public.settings enable row level security;
alter table public.sync_state enable row level security;

drop policy if exists "Profiles read" on public.profiles;
drop policy if exists "Profiles insert" on public.profiles;
drop policy if exists "Profiles update" on public.profiles;
drop policy if exists "Profiles delete" on public.profiles;
create policy "Profiles read" on public.profiles
  for select using (id = auth.uid());
create policy "Profiles insert" on public.profiles
  for insert with check (id = auth.uid());
create policy "Profiles update" on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());
create policy "Profiles delete" on public.profiles
  for delete using (id = auth.uid());

drop policy if exists "Devices read" on public.devices;
drop policy if exists "Devices insert" on public.devices;
drop policy if exists "Devices update" on public.devices;
drop policy if exists "Devices delete" on public.devices;
create policy "Devices read" on public.devices
  for select using (user_id = auth.uid());
create policy "Devices insert" on public.devices
  for insert with check (user_id = auth.uid());
create policy "Devices update" on public.devices
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "Devices delete" on public.devices
  for delete using (user_id = auth.uid());

drop policy if exists "Players read" on public.players;
drop policy if exists "Players insert" on public.players;
drop policy if exists "Players update" on public.players;
drop policy if exists "Players delete" on public.players;
create policy "Players read" on public.players
  for select using (user_id = auth.uid());
create policy "Players insert" on public.players
  for insert with check (user_id = auth.uid());
create policy "Players update" on public.players
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "Players delete" on public.players
  for delete using (user_id = auth.uid());

drop policy if exists "Games read" on public.games;
drop policy if exists "Games insert" on public.games;
drop policy if exists "Games update" on public.games;
drop policy if exists "Games delete" on public.games;
create policy "Games read" on public.games
  for select using (user_id = auth.uid());
create policy "Games insert" on public.games
  for insert with check (user_id = auth.uid());
create policy "Games update" on public.games
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "Games delete" on public.games
  for delete using (user_id = auth.uid());

drop policy if exists "Achievements read" on public.achievements;
drop policy if exists "Achievements insert" on public.achievements;
drop policy if exists "Achievements update" on public.achievements;
drop policy if exists "Achievements delete" on public.achievements;
create policy "Achievements read" on public.achievements
  for select using (user_id = auth.uid());
create policy "Achievements insert" on public.achievements
  for insert with check (user_id = auth.uid());
create policy "Achievements update" on public.achievements
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "Achievements delete" on public.achievements
  for delete using (user_id = auth.uid());

drop policy if exists "Settings read" on public.settings;
drop policy if exists "Settings insert" on public.settings;
drop policy if exists "Settings update" on public.settings;
drop policy if exists "Settings delete" on public.settings;
create policy "Settings read" on public.settings
  for select using (user_id = auth.uid());
create policy "Settings insert" on public.settings
  for insert with check (user_id = auth.uid());
create policy "Settings update" on public.settings
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "Settings delete" on public.settings
  for delete using (user_id = auth.uid());

drop policy if exists "Sync state read" on public.sync_state;
drop policy if exists "Sync state insert" on public.sync_state;
drop policy if exists "Sync state update" on public.sync_state;
drop policy if exists "Sync state delete" on public.sync_state;
create policy "Sync state read" on public.sync_state
  for select using (user_id = auth.uid());
create policy "Sync state insert" on public.sync_state
  for insert with check (user_id = auth.uid());
create policy "Sync state update" on public.sync_state
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "Sync state delete" on public.sync_state
  for delete using (user_id = auth.uid());

create table if not exists public.shot_events (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references public.games(id) on delete cascade,
  player_id uuid not null references public.players(id) on delete cascade,
  turn_index integer not null,
  shot_index integer not null,
  event_type text not null,
  payload jsonb not null,
  ts timestamptz not null,
  created_at timestamptz not null default now(),
  unique (game_id, turn_index, shot_index)
);

create index if not exists shot_events_game_ts_idx
  on public.shot_events (game_id, ts);

create index if not exists shot_events_game_turn_shot_idx
  on public.shot_events (game_id, turn_index, shot_index);

create index if not exists shot_events_player_ts_idx
  on public.shot_events (player_id, ts);

alter table public.shot_events enable row level security;

drop policy if exists "Shot events read" on public.shot_events;
drop policy if exists "Shot events insert" on public.shot_events;
drop policy if exists "Shot events update" on public.shot_events; /* Should be append-only, but sync might need it? strictly speaking append-only means no updates, but we might want to allow it for sync resolution if needed, though strictly append-only is better */
/* Actually, let's stick to read/insert for now to enforce append-only logic at RLS level if possible, but standard sync might try to update? Let's assume standard policies for now. */

create policy "Shot events read" on public.shot_events
  for select using (
    exists (
      select 1 from public.games
      where id = shot_events.game_id
      and user_id = auth.uid()
    )
  );

create policy "Shot events insert" on public.shot_events
  for insert with check (
    exists (
      select 1 from public.games
      where id = shot_events.game_id
      and user_id = auth.uid()
    )
  );

/* No update policy to enforce append-only nature? 
   If we need to correct, we use compensating events as per spec.
   However, DELETE might be needed for cascading deletes from games/users which is handled by FK cascade. 
   But strictly speaking, no manual updates allowed.
*/

commit;
