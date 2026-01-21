import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../services/ad_service.dart';
import '../services/purchase_service.dart';

/// Widget que exibe um banner de anúncio
/// Não mostra nada se o usuário for premium ou em plataformas não suportadas
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // Não carrega em plataformas não suportadas
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return;
    }

    final adService = AdService();
    if (adService.isBannerLoaded && adService.bannerAd != null) {
      setState(() {
        _bannerAd = adService.bannerAd;
        _isLoaded = true;
      });
    } else {
      // Carrega um novo banner
      adService.loadBannerAd().then((_) {
        if (mounted && adService.isBannerLoaded) {
          setState(() {
            _bannerAd = adService.bannerAd;
            _isLoaded = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se é premium
    final purchaseService = context.watch<PurchaseService>();
    if (purchaseService.isPremium) {
      return const SizedBox.shrink();
    }

    // Não mostra em plataformas não suportadas
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return const SizedBox.shrink();
    }

    if (!_isLoaded || _bannerAd == null) {
      // Espaço reservado enquanto carrega
      return const SizedBox(height: 50);
    }

    return Container(
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

/// Container para banner na parte inferior da tela
class BottomAdBanner extends StatelessWidget {
  const BottomAdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final purchaseService = context.watch<PurchaseService>();
    
    // Não mostra se for premium
    if (purchaseService.isPremium) {
      return const SizedBox.shrink();
    }

    // Não mostra em plataformas não suportadas
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      child: const SafeArea(
        top: false,
        child: AdBannerWidget(),
      ),
    );
  }
}
