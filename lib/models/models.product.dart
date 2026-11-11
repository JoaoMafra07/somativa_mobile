// Critério 6: modelo Dart que representa e converte produtos da API REST.
class Product {
  const Product({
    this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    this.imagemUrl,
  });

  final String? id;
  final String nome;
  final String descricao;
  final double preco;
  final String? imagemUrl;

  // A API pode nomear a mesma informação em português ou inglês.
  static String? imagemUrlFromJson(Map<String, dynamic> json) {
    const imageKeys = [
      'imagemUrl',
      'imageUrl',
      'imagem_url',
      'image_url',
      'urlImagem',
      'url_imagem',
      'imagem',
      'image',
      'fotoUrl',
      'foto',
      'img',
      'thumbnail',
    ];

    for (final key in imageKeys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['preco'] ?? json['price'] ?? 0;
    return Product(
      id: json['id']?.toString(),
      nome: (json['nome'] ?? json['name'] ?? 'Produto').toString(),
      descricao: (json['descricao'] ?? json['description'] ?? '').toString(),
      preco: rawPrice is num
          ? rawPrice.toDouble()
          : double.tryParse(rawPrice.toString().replaceAll(',', '.')) ?? 0,
      imagemUrl: imagemUrlFromJson(json),
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'nome': nome,
    'descricao': descricao,
    'preco': preco,
    if (imagemUrl != null && imagemUrl!.trim().isNotEmpty)
      'imagemUrl': imagemUrl!.trim(),
  };
}
