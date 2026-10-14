create table public.submissions (
  answer text not null check (answer ~ '^[A-Za-z]{8}$'),
  submitted_at timestamptz not null default now()
);

alter table public.submissions enable row level security;

revoke all on table public.submissions from anon, authenticated;
grant insert (answer) on table public.submissions to anon;

create policy "Visitors can submit eight-letter answers"
on public.submissions
for insert
to anon
with check (answer ~ '^[A-Za-z]{8}$');