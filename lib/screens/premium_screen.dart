import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/purchase_service.dart';
import '../theme/app_theme.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Versão Premium'),
        centerTitle: true,
      ),
      body: Consumer<PurchaseService>(
        builder: (context, purchaseService, child) {
          if (purchaseService.isPremium) {
            return _buildPremiumActive(context);
          }
          return _buildUpgradeOffer(context, purchaseService);
        },
      ),
    );
  }

  Widget _buildPremiumActive(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 80,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Você é Premium! 🎉',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Obrigado por apoiar o Tarefas em Casa!\nVocê está aproveitando o app sem anúncios.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            const _PremiumFeaturesList(isActive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeOffer(BuildContext context, PurchaseService service) {
    final product = service.premiumProduct;
    final price = product?.price ?? 'R\$ 9,99';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header com ícone
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.1),
                  Colors.amber.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium,
              size: 80,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 24),
          
          // Título
          Text(
            'Seja Premium',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Remova os anúncios e aproveite\numa experiência completa!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // Lista de benefícios
          const _PremiumFeaturesList(isActive: false),
          const SizedBox(height: 32),

          // Preço e botão de compra
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Pagamento único',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Para sempre • Sem assinatura',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Botão de compra
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: service.isLoading
                        ? null
                        : () => _handlePurchase(context, service),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: service.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_cart),
                              SizedBox(width: 8),
                              Text(
                                'Comprar Premium',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Erro, se houver
          if (service.error != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade400),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      service.error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Restaurar compras
          TextButton(
            onPressed: service.isLoading
                ? null
                : () => _handleRestore(context, service),
            child: const Text('Restaurar compras anteriores'),
          ),
          
          const SizedBox(height: 24),
          
          // Texto legal
          Text(
            'A compra é processada pela ${_getStoreName()}. '
            'O valor será cobrado uma única vez e você terá acesso '
            'permanente aos benefícios premium.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  String _getStoreName() {
    // Em produção, verificar a plataforma
    return 'Google Play Store';
  }

  Future<void> _handlePurchase(
    BuildContext context,
    PurchaseService service,
  ) async {
    final success = await service.buyPremium();
    
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(service.error ?? 'Erro ao processar compra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleRestore(
    BuildContext context,
    PurchaseService service,
  ) async {
    await service.restorePurchases();
    
    if (context.mounted) {
      if (service.isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compra restaurada com sucesso! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma compra anterior encontrada'),
          ),
        );
      }
    }
  }
}

class _PremiumFeaturesList extends StatelessWidget {
  final bool isActive;
  
  const _PremiumFeaturesList({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature(
        icon: Icons.block,
        title: 'Sem anúncios',
        description: 'Navegue pelo app sem interrupções',
      ),
      _Feature(
        icon: Icons.favorite,
        title: 'Apoie o desenvolvimento',
        description: 'Ajude a manter o app atualizado',
      ),
      _Feature(
        icon: Icons.all_inclusive,
        title: 'Acesso vitalício',
        description: 'Pague uma vez, use para sempre',
      ),
    ];

    return Column(
      children: features
          .map((f) => _FeatureTile(feature: f, isActive: isActive))
          .toList(),
    );
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String description;

  _Feature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _FeatureTile extends StatelessWidget {
  final _Feature feature;
  final bool isActive;

  const _FeatureTile({
    required this.feature,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green.shade100
                  : AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isActive ? Icons.check : feature.icon,
              color: isActive ? Colors.green : AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  feature.description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
