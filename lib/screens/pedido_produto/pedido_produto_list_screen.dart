import 'package:flutter/material.dart';
import '../../models/pedido_produto.dart';
import '../../repositories/pedido_produto_repository.dart';
import 'pedido_produto_form_screen.dart';

class PedidoProdutoListScreen extends StatefulWidget {
  const PedidoProdutoListScreen({super.key});

  @override
  State<PedidoProdutoListScreen> createState() =>
      _PedidoProdutoListScreenState();
}

class _PedidoProdutoListScreenState extends State<PedidoProdutoListScreen> {
  final _repository = PedidoProdutoRepository();
  List<PedidoProduto> _itens = [];
  bool _carregando = true;
  final _pedidoIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _carregarTodos();
  }

  Future<void> _carregarTodos() async {
    setState(() => _carregando = true);
    try {
      final itens = await _repository.listarPorPedido(0);
      setState(() {
        _itens = itens;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
    }
  }

  Future<void> _buscarPorPedido() async {
    final id = int.tryParse(_pedidoIdController.text);
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um ID válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _carregando = true);
    try {
      final itens = await _repository.listarPorPedido(id);
      setState(() {
        _itens = itens;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deletar(int id) async {
    try {
      await _repository.deletar(id);
      _buscarPorPedido();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao deletar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itens de Pedido'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pedidoIdController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por ID do Pedido',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _buscarPorPedido,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _itens.isEmpty
                ? const Center(child: Text('Nenhum item encontrado.'))
                : ListView.builder(
                    itemCount: _itens.length,
                    itemBuilder: (context, index) {
                      final item = _itens[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.purple,
                          child: Icon(Icons.list_alt, color: Colors.white),
                        ),
                        title: Text(
                          'Pedido #${item.pedidoId} — Produto #${item.produtoId}',
                        ),
                        subtitle: Text(
                          'Qtd: ${item.quantidade} | Unit: R\$ ${item.precoUnit.toStringAsFixed(2)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PedidoProdutoFormScreen(item: item),
                                  ),
                                );
                                _buscarPorPedido();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletar(item.id!),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PedidoProdutoFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
