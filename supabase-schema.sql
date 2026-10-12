create table if not exists public.user_collections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  card_id text not null,
  card_data jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, card_id)
);

create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists handle_updated_at on public.user_collections;
create trigger handle_updated_at
before update on public.user_collections
for each row
execute procedure public.handle_updated_at();

alter table public.user_collections enable row level security;

create policy "Users can view their own collection"
on public.user_collections for select
to authenticated
using (auth.uid() = user_id);

create policy "Users can insert their own collection"
on public.user_collections for insert
to authenticated
with check (auth.uid() = user_id);

create policy "Users can update their own collection"
on public.user_collections for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete their own collection"
on public.user_collections for delete
to authenticated
using (auth.uid() = user_id);
