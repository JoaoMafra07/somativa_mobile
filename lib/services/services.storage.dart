import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.product.dart';
import '../models/models.promotional_product.dart';

class StorageService {
  static const _userNameKey = 'nome_usuario';
  static const _productsCacheKey = 'produtos_cache_json';

  // Critério 7: modificações no armazenamento interno com SharedPreferences.
  Future<String> carregarNomeUsuario() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_userNameKey) ?? 'fã otaku';
  }

  Future<void> salvarNomeUsuario(String nome) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_userNameKey, nome);
  }

  // Critério 7: cache do JSON em diretório temporário do aplicativo.
  Future<void> salvarCacheProdutos(List<Product> products) async {
    final json = jsonEncode(products.map((product) => product.toJson()).toList());
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/produtos_cache.json');
      await file.writeAsString(json, flush: true);
    } catch (_) {
      // Alternativa para plataformas sem implementação do diretório temporário.
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_productsCacheKey, json);
    }
  }

  Future<List<Product>> carregarCacheProdutos() async {
    String? json;
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/produtos_cache.json');
      if (await file.exists()) json = await file.readAsString();
    } catch (_) {
      // Usa SharedPreferences quando path_provider não estiver disponível.
    }
    json ??= (await SharedPreferences.getInstance()).getString(_productsCacheKey);
    if (json == null) return [];

    final decoded = jsonDecode(json);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(
          (json) => json.containsKey('descontoPercentual')
              ? PromotionalProduct.fromJson(json)
              : Product.fromJson(json),
        )
        .toList();
  }
}
