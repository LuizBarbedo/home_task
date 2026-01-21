-- ============================================================
-- SCRIPT SQL PARA CRIAR AS TABELAS NO SUPABASE
-- ============================================================
-- Execute este script no SQL Editor do Supabase:
-- 1. Acesse seu projeto no Supabase
-- 2. Vá em "SQL Editor" no menu lateral
-- 3. Cole este script e clique em "Run"
-- ============================================================

-- Habilitar extensão UUID se não estiver habilitada
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- TABELA: users (Perfis dos usuários)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    avatar_url TEXT,
    group_id UUID,
    is_admin BOOLEAN DEFAULT FALSE,
    weekly_points INTEGER DEFAULT 0,
    total_points INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_users_group_id ON public.users(group_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- ============================================================
-- TABELA: groups (Grupos/Famílias)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    code TEXT NOT NULL UNIQUE,
    admin_id UUID NOT NULL REFERENCES public.users(id),
    member_ids UUID[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    week_start_date TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_groups_code ON public.groups(code);
CREATE INDEX IF NOT EXISTS idx_groups_admin_id ON public.groups(admin_id);

-- ============================================================
-- TABELA: tasks (Tarefas domésticas)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    category INTEGER NOT NULL DEFAULT 0,
    frequency INTEGER NOT NULL DEFAULT 0,
    points INTEGER NOT NULL DEFAULT 10,
    created_by UUID NOT NULL REFERENCES public.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_tasks_group_id ON public.tasks(group_id);
CREATE INDEX IF NOT EXISTS idx_tasks_is_active ON public.tasks(is_active);

-- ============================================================
-- TABELA: task_completions (Registro de tarefas concluídas)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.task_completions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task_id UUID NOT NULL REFERENCES public.tasks(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    points_earned INTEGER NOT NULL,
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    notes TEXT,
    photo_url TEXT
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_completions_group_id ON public.task_completions(group_id);
CREATE INDEX IF NOT EXISTS idx_completions_user_id ON public.task_completions(user_id);
CREATE INDEX IF NOT EXISTS idx_completions_completed_at ON public.task_completions(completed_at);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Protege os dados para que usuários só vejam dados do seu grupo
-- ============================================================

-- Habilitar RLS em todas as tabelas
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_completions ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- POLÍTICAS DE SEGURANÇA: users
-- ============================================================

-- Usuários podem ver seu próprio perfil e membros do mesmo grupo
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (
        auth.uid() = id OR 
        group_id IN (SELECT group_id FROM public.users WHERE id = auth.uid())
    );

-- Usuários podem atualizar seu próprio perfil
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Usuários podem inserir seu próprio perfil
CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Usuários podem deletar seu próprio perfil
CREATE POLICY "Users can delete own profile" ON public.users
    FOR DELETE USING (auth.uid() = id);

-- ============================================================
-- POLÍTICAS DE SEGURANÇA: groups
-- ============================================================

-- Membros podem ver seu grupo
CREATE POLICY "Members can view their group" ON public.groups
    FOR SELECT USING (
        auth.uid() = ANY(member_ids) OR
        auth.uid() = admin_id
    );

-- Qualquer usuário autenticado pode criar um grupo
CREATE POLICY "Authenticated users can create groups" ON public.groups
    FOR INSERT WITH CHECK (auth.uid() = admin_id);

-- Apenas admin pode atualizar o grupo
CREATE POLICY "Admin can update group" ON public.groups
    FOR UPDATE USING (auth.uid() = admin_id);

-- Política especial para permitir busca por código (para entrar no grupo)
CREATE POLICY "Anyone can search group by code" ON public.groups
    FOR SELECT USING (true);

-- ============================================================
-- POLÍTICAS DE SEGURANÇA: tasks
-- ============================================================

-- Membros do grupo podem ver as tarefas
CREATE POLICY "Group members can view tasks" ON public.tasks
    FOR SELECT USING (
        group_id IN (
            SELECT id FROM public.groups WHERE auth.uid() = ANY(member_ids)
        )
    );

-- Apenas admin pode criar tarefas
CREATE POLICY "Admin can create tasks" ON public.tasks
    FOR INSERT WITH CHECK (
        group_id IN (
            SELECT id FROM public.groups WHERE auth.uid() = admin_id
        )
    );

-- Apenas admin pode atualizar tarefas
CREATE POLICY "Admin can update tasks" ON public.tasks
    FOR UPDATE USING (
        group_id IN (
            SELECT id FROM public.groups WHERE auth.uid() = admin_id
        )
    );

-- Apenas admin pode deletar tarefas
CREATE POLICY "Admin can delete tasks" ON public.tasks
    FOR DELETE USING (
        group_id IN (
            SELECT id FROM public.groups WHERE auth.uid() = admin_id
        )
    );

-- ============================================================
-- POLÍTICAS DE SEGURANÇA: task_completions
-- ============================================================

-- Membros do grupo podem ver as conclusões
CREATE POLICY "Group members can view completions" ON public.task_completions
    FOR SELECT USING (
        group_id IN (
            SELECT id FROM public.groups WHERE auth.uid() = ANY(member_ids)
        )
    );

-- Membros do grupo podem registrar conclusões
CREATE POLICY "Group members can create completions" ON public.task_completions
    FOR INSERT WITH CHECK (
        auth.uid() = user_id AND
        group_id IN (
            SELECT id FROM public.groups WHERE auth.uid() = ANY(member_ids)
        )
    );

-- ============================================================
-- FUNÇÕES AUXILIARES
-- ============================================================

-- Função para atualizar automaticamente o group_id do usuário
-- quando ele entra em um grupo
CREATE OR REPLACE FUNCTION update_user_group()
RETURNS TRIGGER AS $$
BEGIN
    -- Quando member_ids é atualizado em groups
    -- Atualiza o group_id dos usuários correspondentes
    UPDATE public.users 
    SET group_id = NEW.id
    WHERE id = ANY(NEW.member_ids) AND (group_id IS NULL OR group_id != NEW.id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para executar a função quando member_ids mudar
DROP TRIGGER IF EXISTS on_group_members_change ON public.groups;
CREATE TRIGGER on_group_members_change
    AFTER UPDATE OF member_ids ON public.groups
    FOR EACH ROW
    EXECUTE FUNCTION update_user_group();

-- ============================================================
-- DADOS INICIAIS (Opcional - para testes)
-- ============================================================
-- Descomente as linhas abaixo se quiser criar dados de teste

-- INSERT INTO public.groups (name, code, admin_id, member_ids) VALUES
-- ('Família Exemplo', 'TEST01', 'seu-user-id-aqui', ARRAY['seu-user-id-aqui']::UUID[]);
