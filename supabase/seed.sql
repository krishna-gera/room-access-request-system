-- Seed role/profile data after creating auth users in Supabase Auth

insert into public.profiles (id, email, name, role)
select id, email, 'Student 1', 'student' from auth.users where email = 'student1@example.com'
on conflict (id) do update set
  email = excluded.email,
  name = excluded.name,
  role = excluded.role;

insert into public.profiles (id, email, name, role)
select id, email, 'Student 2', 'student' from auth.users where email = 'student2@example.com'
on conflict (id) do update set
  email = excluded.email,
  name = excluded.name,
  role = excluded.role;

insert into public.profiles (id, email, name, role)
select id, email, 'Admin 1', 'admin' from auth.users where email = 'admin1@example.com'
on conflict (id) do update set
  email = excluded.email,
  name = excluded.name,
  role = excluded.role;

insert into public.profiles (id, email, name, role)
select id, email, 'Admin 2', 'admin' from auth.users where email = 'admin2@example.com'
on conflict (id) do update set
  email = excluded.email,
  name = excluded.name,
  role = excluded.role;

insert into public.profiles (id, email, name, role)
select id, email, 'Guard', 'guard' from auth.users where email = 'guard@example.com'
on conflict (id) do update set
  email = excluded.email,
  name = excluded.name,
  role = excluded.role;

insert into public.profiles (id, email, name, role)
select id, email, 'Tech Admin', 'tech_admin' from auth.users where email = 'techadmin@example.com'
on conflict (id) do update set
  email = excluded.email,
  name = excluded.name,
  role = excluded.role;

insert into public.saptak_members (saptak_id, email, is_active) values
('SAP001', 'student1@example.com', true),
('SAP002', 'student2@example.com', true)
on conflict (email) do update set
  saptak_id = excluded.saptak_id,
  is_active = excluded.is_active;
