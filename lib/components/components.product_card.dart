import 'package:flutter/material.dart';

import '../models/models.product.dart';
import '../models/models.promotional_product.dart';

// Critério 11: cartão reutilizável para exibir produto, preço e ações.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final promo = product is PromotionalProduct
        ? product as PromotionalProduct
        : null;
    final price = promo?.precoComDesconto ?? product.preco;
    final theme = Theme.of(context);
    final imageUrl = product.imagemUrl?.trim() ?? '';
    final imageFallback = Icon(
      promo == null ? Icons.auto_awesome_outlined : Icons.sell_outlined,
      color: theme.colorScheme.primary,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFF2E4D7)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: 128,
                      height: 128,
                      color: const Color(0xFFFFF0E3),
                      child: imageUrl.isEmpty
                          ? imageFallback
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) =>
                                  progress == null ? child : imageFallback,
                              errorBuilder: (context, error, stackTrace) =>
                                  imageFallback,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.nome,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (promo != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8C9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '-${promo.descontoPercentual.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Color(0xFF8B4B0B),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              if (product.descricao.isNotEmpty) ...[
                const SizedBox(height: 13),
                Text(
                  product.descricao,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ],
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (promo != null)
                          Text(
                            'R\$ ${product.preco.toStringAsFixed(2)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: const Color(0xFF7D877F),
                            ),
                          ),
                        Text(
                          'R\$ ${price.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Editar produto',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  const SizedBox(width: 4),
                  IconButton.filledTonal(
                    tooltip: 'Excluir produto',
                    onPressed: onDelete,
                    style: IconButton.styleFrom(
                      foregroundColor: const Color(0xFF9B3934),
                      backgroundColor: const Color(0xFFFCEDEC),
                    ),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
