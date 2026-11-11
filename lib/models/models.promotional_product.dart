import 'models.product.dart';

// Critério 11: subclasse para representar produtos com desconto.
class PromotionalProduct extends Product {
  const PromotionalProduct({
    super.id,
    required super.nome,
    required super.descricao,
    required super.preco,
    super.imagemUrl,
    required this.descontoPercentual,
  });

  final double descontoPercentual;

  double get precoComDesconto => preco * (1 - descontoPercentual / 100);

  factory PromotionalProduct.fromJson(Map<String, dynamic> json) {
    final discount = json['descontoPercentual'] ?? json['discountPercent'] ?? 0;
    return PromotionalProduct(
      id: json['id']?.toString(),
      nome: (json['nome'] ?? json['name'] ?? 'Produto').toString(),
      descricao: (json['descricao'] ?? json['description'] ?? '').toString(),
      preco: _toDouble(json['preco'] ?? json['price']),
      imagemUrl: Product.imagemUrlFromJson(json),
      descontoPercentual: _toDouble(discount),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'descontoPercentual': descontoPercentual,
  };
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse((value ?? 0).toString().replaceAll(',', '.')) ?? 0;
}
