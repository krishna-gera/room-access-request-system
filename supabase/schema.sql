-- Room Access Request System - Supabase schema
-- Run this file in Supabase SQL Editor

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  name text not null,
  role text not null check (role in ('student', 'admin', 'guard', 'tech_admin')),
  created_at timestamptz not null default now()
);

create table if not exists public.saptak_members (
  id uuid primary key default gen_random_uuid(),
  saptak_id text unique not null,
  email text unique not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.requests (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references auth.users(id) on delete cascade,
  student_name text not null,
  student_email text not null,
  saptak_id text not null,
  date date not null,
  start_time time not null,
  end_time time not null,
  purpose text not null,
  people_visiting text not null,
  equipments text not null,
  status text not null default 'pending'
    check (status in ('pending', 'approved_1', 'approved_2', 'rejected')),
  approved_by_1 uuid null references auth.users(id),
  approved_at_1 timestamptz null,
  approved_by_2 uuid null references auth.users(id),
  approved_at_2 timestamptz null,
  qr_payload text null,
  created_at timestamptz not null default now()
);

create table if not exists public.approvals (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.requests(id) on delete cascade,
  admin_id uuid not null references auth.users(id) on delete cascade,
  decision text not null check (decision in ('approved', 'rejected')),
  created_at timestamptz not null default now()
);

create index if not exists idx_requests_student_id on public.requests(student_id);
create index if not exists idx_requests_status on public.requests(status);
create index if not exists idx_requests_created_at on public.requests(created_at desc);
create index if not exists idx_approvals_request_id on public.approvals(request_id);
