import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.product.dart';
import '../models/models.promotional_product.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // A URL pode ser sobrescrita com --dart-define=API_BASE_URL=...
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://somativa-api.onrender.com',
  );

  Uri _resourceEndpoint(String resource, [String path = '']) {
    final baseUrl = _baseUrl.replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$baseUrl/$resource$path');
  }

  Uri _endpoint([String path = '']) => _resourceEndpoint('produtos', path);

  Future<Map<String, dynamic>?> autenticarUsuario({
    required String email,
    required String senha,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final uri = _resourceEndpoint('usuarios').replace(
      queryParameters: {'email': normalizedEmail},
    );
    final response = await _client
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));
    _validarResposta(response, 'consultar usuário');

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! List) {
      throw const FormatException('A API precisa retornar uma lista de usuários.');
    }
    for (final item in decoded) {
      if (item is! Map) continue;
      final user = Map<String, dynamic>.from(item);
      final userEmail = user['email']?.toString().trim().toLowerCase();
      final userPassword = user['senha']?.toString();
      if (userEmail == normalizedEmail && userPassword == senha) return user;
    }
    return null;
  }

  Future<void> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final existingResponse = await _client
        .get(
          _resourceEndpoint('usuarios').replace(
            queryParameters: {'email': normalizedEmail},
          ),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 15));
    _validarResposta(existingResponse, 'verificar cadastro');
    final existingUsers = jsonDecode(utf8.decode(existingResponse.bodyBytes));
    if (existingUsers is! List) {
      throw const FormatException('A API precisa retornar uma lista de usuários.');
    }
    if (existingUsers.isNotEmpty) {
      throw StateError('Este e-mail já possui cadastro. Faça login.');
    }

    final response = await _client
        .post(
          _resourceEndpoint('usuarios'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode({
            'nome': nome.trim(),
            'email': normalizedEmail,
            'senha': senha,
          }),
        )
        .timeout(const Duration(seconds: 15));
    _validarResposta(response, 'cadastrar usuário');
  }

  // Critério 8: Comunicação GET para carregar produtos.
  Future<List<Product>> listarProdutos() async {
    final response = await _client
        .get(_endpoint(), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));
    _validarResposta(response, 'carregar produtos');

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! List) {
      throw const FormatException('A API precisa retornar uma lista de produtos.');
    }
    return decoded.map((item) {
      if (item is! Map) throw const FormatException('Produto inválido na resposta.');
      final json = Map<String, dynamic>.from(item);
      if (json.containsKey('descontoPercentual') ||
          json.containsKey('discountPercent')) {
        return PromotionalProduct.fromJson(json);
      }
      return Product.fromJson(json);
    }).toList();
  }

  // Critério 8: Comunicação POST para cadastrar um produto.
  Future<void> criarProduto(Product product) async {
    final response = await _client
        .post(
          _endpoint(),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(product.toJson()..remove('id')),
        )
        .timeout(const Duration(seconds: 15));
    _validarResposta(response, 'cadastrar produto');
  }

  // Critério 8: Comunicação PUT para atualizar um produto existente.
  Future<void> atualizarProduto(Product product) async {
    if (product.id == null || product.id!.isEmpty) {
      throw StateError('O produto não possui identificador para edição.');
    }
    final response = await _client
        .put(
          _endpoint('/${Uri.encodeComponent(product.id!)}'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: jsonEncode(product.toJson()),
        )
        .timeout(const Duration(seconds: 15));
    _validarResposta(response, 'atualizar produto');
  }

  // Critério 8: Comunicação DELETE para excluir um produto.
  Future<void> excluirProduto(String id) async {
    final response = await _client
        .delete(_endpoint('/${Uri.encodeComponent(id)}'))
        .timeout(const Duration(seconds: 15));
    _validarResposta(response, 'excluir produto');
  }

  // Critério desejável: integração de uma segunda API pública sem autenticação.
  Future<String> buscarConselho() async {
    final response = await _client
        .get(Uri.parse('https://api.adviceslip.com/advice'))
        .timeout(const Duration(seconds: 12));
    _validarResposta(response, 'buscar conselho');
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    final slip = decoded is Map ? decoded['slip'] : null;
    final advice = slip is Map ? slip['advice'] : null;
    if (advice is! String || advice.isEmpty) {
      throw const FormatException('A API não retornou um conselho.');
    }
    return advice;
  }

  void _validarResposta(http.Response response, String acao) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Não foi possível $acao (HTTP ${response.statusCode}).');
    }
  }
}
