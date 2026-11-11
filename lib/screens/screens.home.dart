import 'package:flutter/material.dart';

import '../components/components.product_card.dart';
import '../models/models.product.dart';
import '../services/services.api.dart';
import '../services/services.storage.dart';
import 'screens.login.dart';
import 'screens.product_detail.dart';
import 'screens.product_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  final _storage = StorageService();
  List<Product> _products = [];
  String _userName = 'fã otaku';
  bool _loading = true;
  bool _usingCache = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadProducts();
  }

  Future<void> _loadUserName() async {
    try {
      final name = await _storage.carregarNomeUsuario();
      if (mounted) setState(() => _userName = name);
    } catch (_) {
      // A falha da preferência não impede a abertura do catálogo.
    }
  }

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final products = await _api.listarProdutos();
      if (!mounted) return;
      setState(() {
        _products = products;
        _usingCache = false;
        _loading = false;
      });
      try {
        await _storage.salvarCacheProdutos(products);
      } catch (error) {
        _showMessage('Produtos carregados, mas o cache falhou: $error');
      }
    } catch (error) {
      List<Product> cached = [];
      try {
        cached = await _storage.carregarCacheProdutos();
      } catch (_) {
        // O catálogo ainda mostra o estado vazio se o cache não puder ser lido.
      }
      if (!mounted) return;
      setState(() {
        _products = cached;
        _usingCache = cached.isNotEmpty;
        _loadError = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openForm([Product? product]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(api: _api, product: product),
      ),
    );
    if (changed == true) {
      await _loadProducts();
      if (mounted) _showMessage('Catálogo atualizado com sucesso.');
    }
  }

  void _openProduct(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir produto?'),
        content: Text('“${product.nome}” será removido do catálogo.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF9B3934),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;
    if (product.id == null || product.id!.isEmpty) {
      _showMessage('Este produto não tem identificador para exclusão.');
      return;
    }
    try {
      await _api.excluirProduto(product.id!);
      if (!mounted) return;
      setState(() => _products.removeWhere((item) => item.id == product.id));
      try {
        await _storage.salvarCacheProdutos(_products);
      } catch (_) {
        // A exclusão na API continua válida mesmo se a atualização do cache falhar.
      }
      _showMessage('Produto excluído.');
    } catch (error) {
      _showMessage('Não foi possível excluir: $error');
    }
  }

  Future<void> _editUserName() async {
    final controller = TextEditingController(text: _userName);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Como podemos chamar você?'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Seu nome'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    try {
      await _storage.salvarNomeUsuario(name);
      if (mounted) setState(() => _userName = name);
    } catch (error) {
      _showMessage('Não foi possível salvar seu nome: $error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _introCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFEF6C00), Color(0xFFFFA726)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seu universo otaku.\nSeu próximo achado.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Funko Pops e colecionáveis da cultura pop.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Image.asset(
            'lib/assets/logo.png',
            width: 53,
            height: 53
          ),
        ],
      ),
    );
  }

  Widget _connectionNotice() {
    if (_loadError == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DD),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF8B5C12)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _usingCache
                  ? 'Sem conexão com o servidor. Exibindo os últimos produtos salvos.'
                  : 'Não foi possível conectar ao servidor. Confira a conexão e tente novamente.',
              style: const TextStyle(color: Color(0xFF684914), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 38),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEAEEE8)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 44,
            color: Color(0xFF8B988D),
          ),
          const SizedBox(height: 12),
          Text(
            _loadError == null
                ? 'Sua vitrine otaku começa aqui'
                : 'Catálogo vazio',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          Text(
            _loadError == null
                ? 'Cadastre um item para compartilhar sua paixão pela cultura otaku.'
                : 'Conecte-se ao servidor para carregar ou cadastrar itens.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF6D786F), height: 1.4),
          ),
          if (_loadError == null) ...[
            const SizedBox(height: 17),
            OutlinedButton.icon(
              onPressed: _openForm,
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar primeiro produto'),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FEIRA OTAKU',
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.6,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Olá, $_userName',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Editar nome',
            onPressed: _editUserName,
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            tooltip: 'Atualizar catálogo',
            onPressed: _loading ? null : _loadProducts,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Sair da conta',
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
              (route) => false,
            ),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            _introCard(),
            _connectionNotice(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Destaques otaku',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!_loading && _products.isNotEmpty)
                  Text(
                    '${_products.length} itens',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6D786F),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 13),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_products.isEmpty)
              _emptyState()
            else ...[
              if (_usingCache)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Última versão salva no dispositivo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6D786F),
                    ),
                  ),
                ),
              ..._products.map(
                (product) => ProductCard(
                  product: product,
                  onTap: () => _openProduct(product),
                  onEdit: () => _openForm(product),
                  onDelete: () => _deleteProduct(product),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
      ),
    );
  }
}
