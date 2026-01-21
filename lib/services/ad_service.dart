import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/admob_config.dart';

/// Serviço para gerenciar anúncios do Google AdMob
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  bool _isInitialized = false;
  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  bool _isRewardedLoaded = false;
  
  // Contadores para controlar frequência dos anúncios
  int _taskCompletionCount = 0;
  static const int _tasksBeforeInterstitial = 3; // Mostra anúncio a cada 3 tarefas

  /// Getters
  bool get isBannerLoaded => _isBannerLoaded;
  bool get isInterstitialLoaded => _isInterstitialLoaded;
  bool get isRewardedLoaded => _isRewardedLoaded;
  BannerAd? get bannerAd => _bannerAd;

  /// Inicializa o SDK de anúncios
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Não inicializa em plataformas não suportadas (web, desktop)
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      debugPrint('AdMob não suportado nesta plataforma');
      return;
    }
    
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      debugPrint('AdMob inicializado com sucesso');
      
      // Pré-carrega os anúncios
      await loadBannerAd();
      await loadInterstitialAd();
    } catch (e) {
      debugPrint('Erro ao inicializar AdMob: $e');
    }
  }

  /// Retorna o ID do banner baseado na plataforma
  String get _bannerAdUnitId {
    if (AdMobConfig.isTestMode) {
      return Platform.isAndroid 
          ? AdMobConfig.testBannerAndroid 
          : AdMobConfig.testBannerIos;
    }
    return Platform.isAndroid 
        ? AdMobConfig.prodBannerAndroid 
        : AdMobConfig.prodBannerIos;
  }

  /// Retorna o ID do intersticial baseado na plataforma
  String get _interstitialAdUnitId {
    if (AdMobConfig.isTestMode) {
      return Platform.isAndroid 
          ? AdMobConfig.testInterstitialAndroid 
          : AdMobConfig.testInterstitialIos;
    }
    return Platform.isAndroid 
        ? AdMobConfig.prodInterstitialAndroid 
        : AdMobConfig.prodInterstitialIos;
  }

  /// Retorna o ID do rewarded baseado na plataforma
  String get _rewardedAdUnitId {
    return Platform.isAndroid 
        ? AdMobConfig.testRewardedAndroid 
        : AdMobConfig.testRewardedIos;
  }

  // ============================================================
  // BANNER ADS
  // ============================================================

  /// Carrega um banner ad
  Future<void> loadBannerAd() async {
    if (!_isInitialized) return;
    
    _bannerAd?.dispose();
    _isBannerLoaded = false;
    
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerLoaded = true;
          debugPrint('Banner carregado');
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerLoaded = false;
          ad.dispose();
          debugPrint('Falha ao carregar banner: ${error.message}');
        },
        onAdOpened: (ad) => debugPrint('Banner aberto'),
        onAdClosed: (ad) => debugPrint('Banner fechado'),
      ),
    );
    
    await _bannerAd!.load();
  }

  /// Descarta o banner atual
  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  // ============================================================
  // INTERSTITIAL ADS (Tela cheia)
  // ============================================================

  /// Carrega um anúncio intersticial
  Future<void> loadInterstitialAd() async {
    if (!_isInitialized) return;
    
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          debugPrint('Intersticial carregado');
          
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialLoaded = false;
              loadInterstitialAd(); // Pré-carrega o próximo
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialLoaded = false;
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoaded = false;
          debugPrint('Falha ao carregar intersticial: ${error.message}');
        },
      ),
    );
  }

  /// Mostra o anúncio intersticial se estiver carregado
  Future<bool> showInterstitialAd() async {
    if (!_isInterstitialLoaded || _interstitialAd == null) {
      debugPrint('Intersticial não está pronto');
      return false;
    }
    
    await _interstitialAd!.show();
    _interstitialAd = null;
    return true;
  }

  /// Chamado quando uma tarefa é completada
  /// Mostra intersticial a cada X tarefas
  Future<void> onTaskCompleted() async {
    _taskCompletionCount++;
    
    if (_taskCompletionCount >= _tasksBeforeInterstitial) {
      _taskCompletionCount = 0;
      await showInterstitialAd();
    }
  }

  // ============================================================
  // REWARDED ADS (Vídeos com recompensa)
  // ============================================================

  /// Carrega um anúncio rewarded
  Future<void> loadRewardedAd() async {
    if (!_isInitialized) return;
    
    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
          debugPrint('Rewarded carregado');
        },
        onAdFailedToLoad: (error) {
          _isRewardedLoaded = false;
          debugPrint('Falha ao carregar rewarded: ${error.message}');
        },
      ),
    );
  }

  /// Mostra o anúncio rewarded e retorna true se o usuário ganhou a recompensa
  Future<bool> showRewardedAd() async {
    if (!_isRewardedLoaded || _rewardedAd == null) {
      debugPrint('Rewarded não está pronto');
      return false;
    }
    
    bool rewarded = false;
    
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isRewardedLoaded = false;
        loadRewardedAd(); // Pré-carrega o próximo
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isRewardedLoaded = false;
        loadRewardedAd();
      },
    );
    
    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
        debugPrint('Usuário ganhou recompensa: ${reward.amount} ${reward.type}');
      },
    );
    
    _rewardedAd = null;
    return rewarded;
  }

  // ============================================================
  // CLEANUP
  // ============================================================

  /// Libera todos os recursos
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _rewardedAd = null;
    _isBannerLoaded = false;
    _isInterstitialLoaded = false;
    _isRewardedLoaded = false;
  }
}
