import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IDs dos produtos na loja
class PurchaseIds {
  /// ID do produto "Premium" (remove anúncios)
  /// Este ID deve ser o mesmo configurado na Google Play Console e App Store Connect
  static const String premiumId = 'tarefas_premium';
  
  /// Lista de todos os produtos disponíveis
  static const Set<String> allProductIds = {premiumId};
}

/// Serviço para gerenciar compras in-app e status premium
class PurchaseService extends ChangeNotifier {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isPremium = false;
  bool _isLoading = false;
  String? _error;
  
  // Chave para persistir o status premium localmente
  static const String _premiumKey = 'is_premium_user';

  /// Getters
  bool get isAvailable => _isAvailable;
  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ProductDetails> get products => _products;
  
  /// Retorna o produto premium se disponível
  ProductDetails? get premiumProduct {
    try {
      return _products.firstWhere((p) => p.id == PurchaseIds.premiumId);
    } catch (_) {
      return null;
    }
  }

  /// Inicializa o serviço de compras
  Future<void> initialize() async {
    try {
      // Não disponível em plataformas não suportadas
      if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
        debugPrint('In-App Purchase não suportado nesta plataforma');
        return;
      }
      
      // Carrega status premium salvo localmente
      await _loadPremiumStatus();
      
      // Verifica disponibilidade da loja
      _isAvailable = await _inAppPurchase.isAvailable();
      
      if (!_isAvailable) {
        debugPrint('Loja não disponível');
        return;
      }
      
      // Escuta atualizações de compras
      _subscription = _inAppPurchase.purchaseStream.listen(
        _onPurchaseUpdated,
        onDone: _onDone,
        onError: _onError,
      );
      
      // Carrega produtos disponíveis
      await _loadProducts();
      
      // Restaura compras anteriores
      await restorePurchases();
    } catch (e) {
      debugPrint('Erro ao inicializar PurchaseService: $e');
    }
  }

  /// Carrega os produtos da loja
  Future<void> _loadProducts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _inAppPurchase.queryProductDetails(
        PurchaseIds.allProductIds,
      );
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Produtos não encontrados: ${response.notFoundIDs}');
      }
      
      _products = response.productDetails;
      _error = null;
      
      debugPrint('Produtos carregados: ${_products.length}');
      for (var product in _products) {
        debugPrint('  - ${product.id}: ${product.price}');
      }
    } catch (e) {
      _error = 'Erro ao carregar produtos: $e';
      debugPrint(_error);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// Carrega o status premium salvo localmente
  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;
    notifyListeners();
  }

  /// Salva o status premium localmente
  Future<void> _savePremiumStatus(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, isPremium);
    _isPremium = isPremium;
    notifyListeners();
  }

  /// Inicia a compra do produto premium
  Future<bool> buyPremium() async {
    if (!_isAvailable) {
      _error = 'Loja não disponível';
      notifyListeners();
      return false;
    }
    
    final product = premiumProduct;
    if (product == null) {
      _error = 'Produto não encontrado';
      notifyListeners();
      return false;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final purchaseParam = PurchaseParam(productDetails: product);
      
      // Para produtos não-consumíveis (como premium), use buyNonConsumable
      final success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      
      return success;
    } catch (e) {
      _error = 'Erro ao iniciar compra: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Restaura compras anteriores
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      _error = 'Erro ao restaurar compras: $e';
      debugPrint(_error);
    }
    
    _isLoading = false;
    notifyListeners();
  }

  /// Callback quando há atualizações de compras
  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (var purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// Processa uma compra individual
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    debugPrint('Status da compra: ${purchaseDetails.status}');
    
    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        _isLoading = true;
        notifyListeners();
        break;
        
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        // Verifica se é o produto premium
        if (purchaseDetails.productID == PurchaseIds.premiumId) {
          // Verifica a compra (em produção, faça isso no servidor)
          final valid = await _verifyPurchase(purchaseDetails);
          
          if (valid) {
            await _savePremiumStatus(true);
            debugPrint('Premium ativado!');
          }
        }
        
        // Completa a compra
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        
        _isLoading = false;
        _error = null;
        notifyListeners();
        break;
        
      case PurchaseStatus.error:
        _error = purchaseDetails.error?.message ?? 'Erro na compra';
        _isLoading = false;
        notifyListeners();
        debugPrint('Erro na compra: ${purchaseDetails.error}');
        break;
        
      case PurchaseStatus.canceled:
        _isLoading = false;
        notifyListeners();
        debugPrint('Compra cancelada');
        break;
    }
  }

  /// Verifica se a compra é válida
  /// Em produção, faça essa verificação no servidor!
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // TODO: Em produção, envie purchaseDetails.verificationData para seu servidor
    // e valide com a API do Google/Apple
    
    // Por enquanto, apenas aceita a compra
    return true;
  }

  void _onDone() {
    _subscription?.cancel();
  }

  void _onError(dynamic error) {
    debugPrint('Erro no stream de compras: $error');
  }

  /// Limpa erro
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Para desenvolvimento/teste: ativa premium manualmente
  Future<void> debugSetPremium(bool value) async {
    await _savePremiumStatus(value);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
