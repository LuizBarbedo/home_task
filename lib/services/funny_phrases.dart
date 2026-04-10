import 'dart:math';

import '../models/notification_model.dart';

/// Gerador de frases engraçadas, gamificadas e com gírias atuais
/// para as notificações interativas do app.
///
/// Use [FunnyPhrases.generate] para pegar uma frase aleatória de acordo
/// com o tipo de notificação.
class FunnyPhrases {
  static final Random _rng = Random();

  /// Mensagens enviadas pra quem acabou de ser ULTRAPASSADO no ranking.
  /// `{name}` será substituído pelo nome de quem ultrapassou.
  /// `{points}` pelos pontos do ofensor.
  static const List<String> _overtakenMessages = [
    'Eita, {name} te ultrapassou! Vai deixar barato assim, mozi? 😱',
    'Tomou um chapéu de {name}! Vai ficar quieto? 🎩💨',
    'Vish, {name} te passou voadinho com {points} pts. Reage! 🚀',
    'Modo sussa OFF: {name} tá colado em cima de você no ranking 👀',
    '{name} mandou um "tchau, otário" e te deixou pra trás 🏃‍♂️💨',
    'Ô loco, {name} fez modo speedrun e te ratiou kkk',
    'Te tomaram de base, hein. {name} já tá na sua frente 🫠',
    '🚨 INVASÃO 🚨 {name} acabou de te ultrapassar. E agora, José?',
    'Acordou tarde? {name} fez missão diária e te passou 😴',
    'Cadê o foco? {name} te ultrapassou enquanto você scrollava reels 📱',
    '{name} entrou no modo tryhard e tá comendo o seu lanche 🍔',
    'Ranking update: {name} > você. Tá deixando rolar mesmo? 🤨',
    '{name} te deu um overtake digno de F1. Bora pra cima! 🏎️',
    'Ih rapaz, {name} mandou ver e te passou na curva 🌀',
    'Foste neutralizado por {name}. Bora revidar? ⚔️',
    'Tava confortável demais, né? {name} te mostrou que não tem mole 💅',
    'Game on! {name} marcou ponto e tá te encarando do alto 🎮',
    'POV: {name} te ultrapassou e ainda dancinhou no ranking 💃',
    '{name} fez upgrade e você ficou no modo demo 🕹️',
  ];

  /// Mensagens enviadas pra quem PERDEU O 1º LUGAR.
  static const List<String> _throneStolenMessages = [
    '🚨 GOLPE NO TRONO 🚨 {name} te derrubou do 1º lugar! 👑💔',
    'Acabou o reinado, majestade. {name} é o novo TOP 1 👑',
    'Caiu do trono! {name} sentou no seu lugar com {points} pts 💺',
    'O rei caiu! Longa vida a {name}... por enquanto 😏',
    'Tava de boa no #1? Pois é, {name} disse "agora é minha" 👑',
    'Coroa CONFISCADA por {name}. Vai correr atrás ou aceita o vice? 🥈',
    '{name} fez um golpe de estado no ranking. REVOLUÇÃO! ⚔️',
    '👑 ALERTA REAL 👑 Sua coroa foi roubada por {name}!',
    'Era uma vez um líder... aí veio {name} e mudou o final da história 📖',
    'Plot twist: {name} é o novo número 1. Bora retomar o trono! 🔥',
  ];

  /// Mensagens enviadas pra quem está SENDO AMEAÇADO (close call).
  static const List<String> _closeCallMessages = [
    '👀 {name} tá colado em você! Faltam só {diff} pts pra te passar',
    'Atenção! {name} tá no seu pé. {diff} pts de distância 🐾',
    'Olha o retrovisor! {name} tá quase te ultrapassando 🚗💨',
    '{name} tá na cola! Não vacila não, hein 👻',
    'Respira fundo: {name} tá a {diff} pts de te roubar a posição 😬',
  ];

  /// Mensagens quando alguém do grupo COMPLETA uma tarefa.
  static const List<String> _taskCompletedMessages = [
    '{name} mandou ver e fez "{task}" 💪 (+{points} pts)',
    '🔥 {name} arrasou em "{task}" e levou {points} pts',
    '{name} tá no modo produtividade: completou "{task}" 🚀',
    'Plot twist: {name} fez "{task}" antes de você 👀',
    '{name} entregou "{task}" no capricho ✨ (+{points} pts)',
    'PA! {name} fez "{task}" e tá voando no ranking 🦅',
  ];

  /// Mensagens de MILESTONE (bater marcas de pontos).
  static const List<String> _milestoneMessages = [
    '🎉 PARABÉNS! Você bateu {points} pontos! Tá voando, hein 🚀',
    'MARCO DESBLOQUEADO: {points} pts! Você é o cara/mina 🏆',
    '{points} pontos?! Tá imparável! Bora pro próximo nível 🆙',
    'Conquista épica: {points} pts. Continua nesse pique! 💎',
    'Achievement unlocked 🏅 — {points} pontos na conta!',
  ];

  /// Mensagem quando alguém entra no grupo.
  static const List<String> _newMemberMessages = [
    '👋 {name} entrou no grupo! Bora dar boas vindas e mostrar quem manda',
    '🎊 Novo membro na área: {name}! Que comece o jogo',
    '{name} apareceu! Mais um pra disputar o ranking 😎',
    '🚪 {name} entrou no chat... do ranking! Sem dó',
  ];

  /// Reset semanal.
  static const List<String> _weeklyResetMessages = [
    '🔄 Semana zerada! Todo mundo no 0x0. Bora começar do zero!',
    'NOVA TEMPORADA começou 🏁 Quem vai cravar o TOP 1 dessa vez?',
    'Reset feito! Pontuações zeradas. É a sua chance de ser lenda 🌟',
  ];

  /// Emojis de destaque por tipo
  static const Map<AppNotificationType, String> _emojis = {
    AppNotificationType.overtaken: '😤',
    AppNotificationType.throneStolen: '👑',
    AppNotificationType.closeCall: '👀',
    AppNotificationType.taskCompleted: '✅',
    AppNotificationType.milestone: '🏆',
    AppNotificationType.newMember: '🎉',
    AppNotificationType.weeklyReset: '🔄',
  };

  /// Gera uma mensagem engraçada aleatória pra um tipo específico.
  ///
  /// Substitui placeholders nas frases:
  /// - `{name}` → nome do usuário do contexto
  /// - `{points}` → pontos
  /// - `{diff}` → diferença de pontos
  /// - `{task}` → título da tarefa
  static String generate(
    AppNotificationType type, {
    String? name,
    int? points,
    int? diff,
    String? task,
  }) {
    final list = _listFor(type);
    final raw = list[_rng.nextInt(list.length)];
    return raw
        .replaceAll('{name}', name ?? 'Alguém')
        .replaceAll('{points}', '${points ?? 0}')
        .replaceAll('{diff}', '${diff ?? 0}')
        .replaceAll('{task}', task ?? 'uma tarefa');
  }

  /// Retorna o emoji destacado para o tipo.
  static String emojiFor(AppNotificationType type) =>
      _emojis[type] ?? '🔔';

  static List<String> _listFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.overtaken:
        return _overtakenMessages;
      case AppNotificationType.throneStolen:
        return _throneStolenMessages;
      case AppNotificationType.closeCall:
        return _closeCallMessages;
      case AppNotificationType.taskCompleted:
        return _taskCompletedMessages;
      case AppNotificationType.milestone:
        return _milestoneMessages;
      case AppNotificationType.newMember:
        return _newMemberMessages;
      case AppNotificationType.weeklyReset:
        return _weeklyResetMessages;
    }
  }
}
