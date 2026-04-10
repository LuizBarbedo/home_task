-- ============================================================
-- MIGRATION: Sistema de notificações interativas
-- ============================================================
-- Execute este script no SQL Editor do Supabase para habilitar
-- o sistema de notificações engraçadas (overtake, milestone, etc.)
-- ============================================================

-- ============================================================
-- TABELA: notifications
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    from_user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    from_user_name TEXT,
    group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    message TEXT NOT NULL,
    emoji TEXT DEFAULT '🔔',
    is_read BOOLEAN DEFAULT FALSE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_notifications_user_id
    ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_read
    ON public.notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at
    ON public.notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_group_id
    ON public.notifications(group_id);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- O usuário só pode ver as próprias notificações
DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
CREATE POLICY "Users can view own notifications" ON public.notifications
    FOR SELECT USING (auth.uid() = user_id);

-- Qualquer membro do mesmo grupo pode criar notificações para outro membro
-- (necessário pra disparar notificações de overtake quando você completa tarefa)
DROP POLICY IF EXISTS "Group members can create notifications" ON public.notifications;
CREATE POLICY "Group members can create notifications" ON public.notifications
    FOR INSERT WITH CHECK (
        group_id IN (
            SELECT id FROM public.groups WHERE auth.uid() = ANY(member_ids)
        )
    );

-- O usuário pode atualizar suas próprias notificações (ex: marcar como lida)
DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
CREATE POLICY "Users can update own notifications" ON public.notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- O usuário pode deletar suas próprias notificações
DROP POLICY IF EXISTS "Users can delete own notifications" ON public.notifications;
CREATE POLICY "Users can delete own notifications" ON public.notifications
    FOR DELETE USING (auth.uid() = user_id);

-- ============================================================
-- REALTIME
-- ============================================================
-- Habilita o realtime para a tabela notifications
-- (necessário pra receber os pings ao vivo no app)
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;

-- ============================================================
-- LIMPEZA AUTOMÁTICA (opcional)
-- ============================================================
-- Função para deletar notificações antigas (mais de 30 dias).
-- Você pode chamar isso periodicamente via pg_cron, ou manualmente.
CREATE OR REPLACE FUNCTION public.cleanup_old_notifications()
RETURNS void AS $$
BEGIN
    DELETE FROM public.notifications
    WHERE created_at < NOW() - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
