create table if not exists public.submissions (
  answer text not null check (answer ~ '^[A-Za-z]{8}$'),
  submitted_at timestamptz not null default now()
);

alter table public.submissions enable row level security;

revoke all on table public.submissions from anon, authenticated;
grant insert (answer) on public.submissions to anon;

drop policy if exists "Visitors can submit eight-letter answers"
on public.submissions;

create policy "Visitors can submit eight-letter answers"
on public.submissions
for insert
to anon
with check (answer ~ '^[A-Za-z]{8}$');

create table if not exists public.submission_rate_limits (
  ip_address inet not null,
  hour_start timestamptz not null,
  attempts smallint not null check (attempts between 1 and 20),
  primary key (ip_address, hour_start)
);

create index if not exists submission_rate_limits_hour_start_idx
on public.submission_rate_limits (hour_start);

alter table public.submission_rate_limits enable row level security;
revoke all on table public.submission_rate_limits from anon, authenticated;

create or replace function public.enforce_submission_hourly_limit()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  request_headers jsonb;
  client_ip_text text;
  client_ip inet;
  current_hour timestamptz := date_trunc('hour', now() at time zone 'UTC') at time zone 'UTC';
  accepted_attempt smallint;
begin
  request_headers := nullif(current_setting('request.headers', true), '')::jsonb;
  client_ip_text := coalesce(
    nullif(btrim(request_headers ->> 'cf-connecting-ip'), ''),
    nullif(btrim(request_headers ->> 'x-real-ip'), ''),
    nullif(btrim(split_part(request_headers ->> 'x-forwarded-for', ',', 1)), '')
  );

  if client_ip_text is null then
    raise exception 'Unable to determine client IP address'
      using errcode = '42501';
  end if;

  begin
    client_ip := host(client_ip_text::inet)::inet;
  exception
    when invalid_text_representation then
      raise exception 'Unable to determine client IP address'
        using errcode = '42501';
  end;

  delete from public.submission_rate_limits
  where hour_start < current_hour;

  insert into public.submission_rate_limits (ip_address, hour_start, attempts)
  values (client_ip, current_hour, 1)
  on conflict (ip_address, hour_start)
  do update set attempts = public.submission_rate_limits.attempts + 1
  where public.submission_rate_limits.attempts < 20
  returning attempts into accepted_attempt;

  if accepted_attempt is null then
    raise exception 'Hourly submission limit reached'
      using errcode = 'P0001';
  end if;

  return new;
end;
$$;

revoke all on function public.enforce_submission_hourly_limit()
from public, anon, authenticated;

drop trigger if exists enforce_submission_hourly_limit
on public.submissions;

create trigger enforce_submission_hourly_limit
before insert on public.submissions
for each row
execute function public.enforce_submission_hourly_limit();

create or replace function public.get_submission_attempt_count()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  request_headers jsonb;
  client_ip_text text;
  client_ip inet;
  current_hour timestamptz := date_trunc('hour', now() at time zone 'UTC') at time zone 'UTC';
begin
  request_headers := nullif(current_setting('request.headers', true), '')::jsonb;
  client_ip_text := coalesce(
    nullif(btrim(request_headers ->> 'cf-connecting-ip'), ''),
    nullif(btrim(request_headers ->> 'x-real-ip'), ''),
    nullif(btrim(split_part(request_headers ->> 'x-forwarded-for', ',', 1)), '')
  );

  if client_ip_text is null then
    raise exception 'Unable to determine client IP address'
      using errcode = '42501';
  end if;

  begin
    client_ip := host(client_ip_text::inet)::inet;
  exception
    when invalid_text_representation then
      raise exception 'Unable to determine client IP address'
        using errcode = '42501';
  end;

  return coalesce(
    (
      select attempts::integer
      from public.submission_rate_limits
      where ip_address = client_ip
        and hour_start = current_hour
    ),
    0
  );
end;
$$;

revoke all on function public.get_submission_attempt_count()
from public, anon, authenticated;
grant execute on function public.get_submission_attempt_count() to anon;
