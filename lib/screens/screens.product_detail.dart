import 'package:flutter/material.dart';

import '../models/models.product.dart';
import '../models/models.promotional_product.dart';
import '../services/services.api.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _api = ApiService();

  Product get _product => widget.product;

  double get _unitPrice => _product is PromotionalProduct
      ? (_product as PromotionalProduct).precoComDesconto
      : _product.preco;

  Future<void> _buy() async {
    var advice = 'Boas compras e bom passeio pelo universo otaku!';
    try {
      advice = await _api.buscarConselho();
    } catch (_) {
      // A compra continua mesmo se a API de conselhos estiver indisponível.
    }
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.auto_awesome_outlined, size: 34),
        title: const Text('Compra concluída'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Produto comprado com sucesso!'),
            const SizedBox(height: 14),
            Text('Dica do dia: $advice'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    final imageUrl = _product.imagemUrl?.trim() ?? '';
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          color: const Color(0xFFFFF0E3),
          child: imageUrl.isEmpty
              ? const Icon(
                  Icons.auto_awesome_outlined,
                  size: 78,
                  color: Color(0xFFEF6C00),
                )
              : Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image_outlined,
                    size: 78,
                    color: Color(0xFFEF6C00),
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final promo = _product is PromotionalProduct
        ? _product as PromotionalProduct
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do produto')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _buildProductImage(),
          const SizedBox(height: 22),
          if (promo != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8C9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  '-${promo.descontoPercentual.toStringAsFixed(0)}% de desconto',
                  style: const TextStyle(
                    color: Color(0xFF8B4B0B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            _product.nome,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (_product.descricao.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _product.descricao,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF765C49),
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 18),
          if (promo != null)
            Text(
              'R\$ ${_product.preco.toStringAsFixed(2)}',
              style: theme.textTheme.bodyLarge?.copyWith(
                decoration: TextDecoration.lineThrough,
                color: const Color(0xFF7D877F),
              ),
            ),
          Text(
            'R\$ ${_unitPrice.toStringAsFixed(2)} cada',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: FilledButton.icon(
            onPressed: _buy,
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Comprar'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
          ),
        ),
      ),
    );
  }
}
