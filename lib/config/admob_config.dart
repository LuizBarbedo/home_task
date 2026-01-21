/// Configurações do Google AdMob
/// 
/// IMPORTANTE: Substitua os IDs abaixo pelos IDs reais do seu AdMob.
/// 
/// Para obter os IDs:
/// 1. Acesse https://admob.google.com
/// 2. Crie um app e configure os blocos de anúncios
/// 3. Copie os IDs gerados
/// 
/// Os IDs abaixo são IDs DE TESTE do Google - use-os durante o desenvolvimento.
class AdMobConfig {
  // ============================================================
  // IDs DO APP (substitua pelos seus IDs de produção)
  // ============================================================
  
  /// ID do app Android no AdMob
  /// Formato: ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
  static const String androidAppId = 'ca-app-pub-3940256099942544~3347511713'; // TESTE
  
  /// ID do app iOS no AdMob
  /// Formato: ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
  static const String iosAppId = 'ca-app-pub-3940256099942544~1458002511'; // TESTE
  
  // ============================================================
  // IDs DOS BLOCOS DE ANÚNCIOS - TESTE (funcionam em desenvolvimento)
  // ============================================================
  
  /// Banner - Android (teste)
  static const String testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  
  /// Banner - iOS (teste)
  static const String testBannerIos = 'ca-app-pub-3940256099942544/2934735716';
  
  /// Intersticial - Android (teste)
  static const String testInterstitialAndroid = 'ca-app-pub-7552145998008928/4443899546';
  
  /// Intersticial - iOS (teste)
  static const String testInterstitialIos = 'ca-app-pub-3940256099942544/4411468910';
  
  /// Rewarded (vídeo com recompensa) - Android (teste)
  static const String testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  
  /// Rewarded (vídeo com recompensa) - iOS (teste)
  static const String testRewardedIos = 'ca-app-pub-3940256099942544/1712485313';
  
  // ============================================================
  // IDs DOS BLOCOS DE ANÚNCIOS - PRODUÇÃO (substitua pelos seus)
  // ============================================================
  
  /// Banner - Android (produção)
  /// Substitua pelo seu ID real do AdMob
  static const String prodBannerAndroid = 'ca-app-pub-7552145998008928/6140942837';
  
  /// Banner - iOS (produção)
  /// Substitua pelo seu ID real do AdMob
  static const String prodBannerIos = 'YOUR_BANNER_AD_UNIT_ID_IOS';
  
  /// Intersticial - Android (produção)
  static const String prodInterstitialAndroid = 'ca-app-pub-7552145998008928/4443899546';
  
  /// Intersticial - iOS (produção)
  static const String prodInterstitialIos = 'YOUR_INTERSTITIAL_AD_UNIT_ID_IOS';
  
  // ============================================================
  // CONFIGURAÇÕES
  // ============================================================
  
  /// Define se está em modo de teste
  /// IMPORTANTE: Mude para false antes de publicar!
  static const bool isTestMode = false;
  
  /// Retorna o ID do banner baseado na plataforma e modo
  static String get bannerAdUnitId {
    if (isTestMode) {
      return _isAndroid ? testBannerAndroid : testBannerIos;
    }
    return _isAndroid ? prodBannerAndroid : prodBannerIos;
  }
  
  /// Retorna o ID do intersticial baseado na plataforma e modo
  static String get interstitialAdUnitId {
    if (isTestMode) {
      return _isAndroid ? testInterstitialAndroid : testInterstitialIos;
    }
    return _isAndroid ? prodInterstitialAndroid : prodInterstitialIos;
  }
  
  /// Retorna o ID do rewarded baseado na plataforma
  static String get rewardedAdUnitId {
    return _isAndroid ? testRewardedAndroid : testRewardedIos;
  }
  
  /// Helper para verificar plataforma
  static bool get _isAndroid {
    // Será verificado em runtime
    return true; // Placeholder - será substituído pelo serviço
  }
}
