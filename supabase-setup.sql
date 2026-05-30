-- ============================================================
-- QuantBR — Tabela de alertas no Supabase
-- Como usar: abra o Supabase > seu projeto > SQL Editor >
-- cole tudo isto > clique em "Run". Pronto, a tabela é criada.
-- ============================================================

create table if not exists public.alerts (
  id          bigint generated always as identity primary key,
  email       text        not null,
  ticker      text        not null,
  condition   text        not null check (condition in ('above','below')),
  target      numeric     not null,
  triggered   boolean     not null default false,
  triggered_at timestamptz,
  created_at  timestamptz not null default now()
);

-- índice para o "carteiro" achar rápido os alertas pendentes
create index if not exists alerts_pending_idx
  on public.alerts (triggered) where triggered = false;

-- índice para listar alertas por e-mail
create index if not exists alerts_email_idx on public.alerts (email);

-- Segurança: ativamos RLS (Row Level Security).
-- O acesso é feito SOMENTE pelas funções do Netlify, que usam a
-- chave "service_role" (que ignora RLS por padrão). O navegador
-- nunca fala direto com esta tabela, então não criamos políticas
-- públicas — fica fechado por padrão, que é o mais seguro.
alter table public.alerts enable row level security;
