/// Configurações do Supabase
/// 
/// IMPORTANTE: Substitua os valores abaixo pelas credenciais do seu projeto Supabase.
/// 
/// Para obter essas credenciais:
/// 1. Acesse https://supabase.com e crie uma conta gratuita
/// 2. Crie um novo projeto
/// 3. Vá em Settings > API
/// 4. Copie a "Project URL" e a "anon public" key
class SupabaseConfig {
  /// URL do seu projeto Supabase
  /// Exemplo: https://xyzcompany.supabase.co
  static const String supabaseUrl = 'https://ivjtwxvfavpfridhsmbt.supabase.co';
  
  /// Chave anônima pública (anon key)
  /// Esta chave é segura para usar no cliente
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml2anR3eHZmYXZwZnJpZGhzbWJ0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg0MjExNzAsImV4cCI6MjA4Mzk5NzE3MH0.99DOeIewz9kbhN9NjS8zpT0jLYlWOHC0s1qp12MiJD8';
  
  /// Verifica se as credenciais foram configuradas
  /// Retorna true se NÃO forem os placeholders padrão
  static bool get isConfigured => 
      supabaseUrl != 'YOUR_SUPABASE_URL' && 
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
}
