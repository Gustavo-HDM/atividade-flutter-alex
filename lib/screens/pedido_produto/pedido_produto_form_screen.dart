import 'package:flutter/material.dart';
import '../../models/pedido_produto.dart';
import '../../models/pedido.dart';
import '../../models/produto.dart';
import '../../repositories/pedido_produto_repository.dart';
import '../../repositories/pedido_repository.dart';
import '../../repositories/produto_repository.dart';

class PedidoProdutoFormScreen extends StatefulWidget {
  final PedidoProduto? item;

  const PedidoProdutoFormScreen({super.key, this.item});

  @override
  State<PedidoProdutoFormScreen> createState() =>
      _PedidoProdutoFormScreenState();
}

class _PedidoProdutoFormScreenState extends State<PedidoProdutoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = PedidoProdutoRepository();
  final _pedidoRepository = PedidoRepository();
  final _produtoRepository = ProdutoRepository();
  final _quantidadeController = TextEditingController();
  final _precoUnitController = TextEditingController();

  List<Pedido> _pedidos = [];
  List<Produto> _produtos = [];
  int? _pedidoSelecionado;
  int? _produtoSelecionado;
  bool _salvando = false;
  bool _carregando = true;

  bool get _editando => widget.item != null;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final pedidos = await _pedidoRepository.listarTodos();
      final produtos = await _produtoRepository.listarTodos();
      setState(() {
        _pedidos = pedidos;
        _produtos = produtos;
        _carregando = false;
        if (_editando) {
          _pedidoSelecionado = widget.item!.pedidoId;
          _produtoSelecionado = widget.item!.produtoId;
          _quantidadeController.text = widget.item!.quantidade.toString();
          _precoUnitController.text = widget.item!.precoUnit.toStringAsFixed(2);
        }
      });
    } catch (e) {
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _precoUnitController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pedidoSelecionado == null || _produtoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o pedido e o produto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      final item = PedidoProduto(
        id: widget.item?.id,
        pedidoId: _pedidoSelecionado!,
        produtoId: _produtoSelecionado!,
        quantidade: int.parse(_quantidadeController.text),
        precoUnit: double.parse(_precoUnitController.text.replaceAll(',', '.')),
      );

      if (_editando) {
        await _repository.atualizar(item);
      } else {
        await _repository.inserir(item);
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
        title: Text(_editando ? 'Editar Item' : 'Novo Item'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<int>(
                      value: _pedidoSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Pedido *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.receipt),
                      ),
                      items: _pedidos.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text('Pedido #${p.id} — ${p.status}'),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _pedidoSelecionado = v),
                      validator: (v) =>
                          v == null ? 'Selecione um pedido' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _produtoSelecionado,
                      decoration: const InputDecoration(
                        labelText: 'Produto *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                      items: _produtos.map((p) {
                        return DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            '${p.nome} — R\$ ${p.preco.toStringAsFixed(2)}',
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _produtoSelecionado = v),
                      validator: (v) =>
                          v == null ? 'Selecione um produto' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Informe a quantidade';
                        if (int.tryParse(v) == null)
                          return 'Quantidade inválida';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _precoUnitController,
                      decoration: const InputDecoration(
                        labelText: 'Preço Unitário *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _salvando ? null : _salvar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        child: _salvando
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
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
