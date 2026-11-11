import 'package:flutter/material.dart';

import '../components/components.custom_input.dart';
import '../models/models.product.dart';
import '../models/models.promotional_product.dart';
import '../services/services.api.dart';

class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, required this.api, this.product});

  final ApiService api;
  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _discountController;
  bool _isPromotional = false;
  bool _saving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    final promo = product is PromotionalProduct ? product : null;
    _nameController = TextEditingController(text: product?.nome ?? '');
    _descriptionController = TextEditingController(
      text: product?.descricao ?? '',
    );
    _priceController = TextEditingController(
      text: product == null ? '' : product.preco.toStringAsFixed(2),
    );
    _imageUrlController = TextEditingController(text: product?.imagemUrl ?? '');
    _discountController = TextEditingController(
      text: promo?.descontoPercentual.toStringAsFixed(0) ?? '10',
    );
    _isPromotional = promo != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  double _numberFrom(TextEditingController controller) =>
      double.parse(controller.text.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final price = _numberFrom(_priceController);
    final common = {
      'id': widget.product?.id,
      'nome': _nameController.text.trim(),
      'descricao': _descriptionController.text.trim(),
      'preco': price,
      'imagemUrl': _imageUrlController.text.trim(),
    };
    final Product product = _isPromotional
        ? PromotionalProduct(
            id: common['id'] as String?,
            nome: common['nome'] as String,
            descricao: common['descricao'] as String,
            preco: price,
            imagemUrl: common['imagemUrl'] as String,
            descontoPercentual: _numberFrom(_discountController),
          )
        : Product(
            id: common['id'] as String?,
            nome: common['nome'] as String,
            descricao: common['descricao'] as String,
            preco: price,
            imagemUrl: common['imagemUrl'] as String,
          );

    try {
      if (_isEditing) {
        await widget.api.atualizarProduto(product);
      } else {
        await widget.api.criarProduto(product);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível salvar: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return 'Informe $label.';
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe o preço.';
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return 'Digite um preço maior que zero.';
    return null;
  }

  String? _validateImageUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null ||
        !{'http', 'https'}.contains(uri.scheme.toLowerCase()) ||
        uri.host.isEmpty) {
      return 'Informe uma URL válida começando com http:// ou https://.';
    }
    return null;
  }

  String? _validateDiscount(String? value) {
    final parsed = double.tryParse((value ?? '').replaceAll(',', '.'));
    if (parsed == null || parsed <= 0 || parsed > 100) {
      return 'Use um desconto entre 1% e 100%.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar produto' : 'Novo produto'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(
                _isEditing
                    ? 'Atualize as informações do produto.'
                    : 'Adicione um item à vitrine da Feira Otaku.',
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: const Color(0xFF667269)),
              ),
              const SizedBox(height: 24),
              CustomInput(
                controller: _nameController,
                label: 'Nome do produto',
                icon: Icons.inventory_2_outlined,
                validator: (value) => _required(value, 'o nome'),
              ),
              const SizedBox(height: 14),
              CustomInput(
                controller: _descriptionController,
                label: 'Descrição',
                hint: 'Conte um pouco sobre o produto',
                icon: Icons.notes_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              CustomInput(
                controller: _imageUrlController,
                label: 'URL da imagem (opcional)',
                hint: 'https://exemplo.com/imagem.jpg',
                icon: Icons.image_outlined,
                keyboardType: TextInputType.url,
                validator: _validateImageUrl,
              ),
              const SizedBox(height: 14),
              CustomInput(
                controller: _priceController,
                label: 'Preço (R\$)',
                hint: '0,00',
                icon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _validatePrice,
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                title: const Text('Produto em promoção'),
                subtitle: const Text('Mostra o valor com desconto no catálogo'),
                value: _isPromotional,
                onChanged: (value) => setState(() => _isPromotional = value),
              ),
              if (_isPromotional) ...[
                const SizedBox(height: 8),
                CustomInput(
                  controller: _discountController,
                  label: 'Desconto (%)',
                  icon: Icons.percent,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _validateDiscount,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_saving ? 'Salvando...' : 'Salvar produto'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
