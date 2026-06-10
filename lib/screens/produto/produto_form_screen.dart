import 'package:flutter/material.dart';
import '../../models/produto.dart';
import '../../repositories/produto_repository.dart';

class ProdutoFormScreen extends StatefulWidget {
  final Produto? produto;

  const ProdutoFormScreen({super.key, this.produto});

  @override
  State<ProdutoFormScreen> createState() => _ProdutoFormScreenState();
}

class _ProdutoFormScreenState extends State<ProdutoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _precoController = TextEditingController();
  final _estoqueController = TextEditingController();
  final _repository = ProdutoRepository();
  bool _salvando = false;

  bool get _editando => widget.produto != null;

  @override
  void initState() {
    super.initState();
    if (_editando) {
      _nomeController.text = widget.produto!.nome;
      _precoController.text = widget.produto!.preco.toStringAsFixed(2);
      _estoqueController.text = widget.produto!.estoque.toString();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _precoController.dispose();
    _estoqueController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final produto = Produto(
        id: widget.produto?.id,
        nome: _nomeController.text.trim(),
        preco: double.parse(_precoController.text.replaceAll(',', '.')),
        estoque: int.parse(_estoqueController.text),
      );

      if (_editando) {
        await _repository.atualizar(produto);
      } else {
        await _repository.inserir(produto);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Produto' : 'Novo Produto'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _precoController,
                decoration: const InputDecoration(
                  labelText: 'Preço *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: '0.00',
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o preço';
                  if (double.tryParse(v.replaceAll(',', '.')) == null) {
                    return 'Preço inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _estoqueController,
                decoration: const InputDecoration(
                  labelText: 'Estoque *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Informe o estoque';
                  if (int.tryParse(v) == null) return 'Estoque inválido';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _salvando ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _salvando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _editando ? 'Salvar Alterações' : 'Cadastrar',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
