import 'package:flutter/material.dart';
import '../../models/pedido_produto.dart';
import '../../models/pedido.dart';
import '../../repositories/pedido_produto_repository.dart';
import '../../repositories/pedido_repository.dart';
import 'pedido_produto_form_screen.dart';

class PedidoProdutoListScreen extends StatefulWidget {
  const PedidoProdutoListScreen({super.key});

  @override
  State<PedidoProdutoListScreen> createState() =>
      _PedidoProdutoListScreenState();
}

class _PedidoProdutoListScreenState extends State<PedidoProdutoListScreen> {
  final _repository = PedidoProdutoRepository();
  final _pedidoRepository = PedidoRepository();

  List<PedidoProduto> _todosItens = [];
  List<PedidoProduto> _itensFiltrados = [];
  List<Pedido> _pedidos = [];
  int? _filtroPedidoId; // null = "Todos"

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarTudo();
  }

  Future<void> _carregarTudo() async {
    setState(() => _carregando = true);
    try {
      final pedidos = await _pedidoRepository.listarTodos();

      // Busca os itens de TODOS os pedidos e junta numa lista só
      final List<PedidoProduto> todos = [];
      for (final pedido in pedidos) {
        final itens = await _repository.listarPorPedido(pedido.id!);
        todos.addAll(itens);
      }

      setState(() {
        _pedidos = pedidos;
        _todosItens = todos;
        _aplicarFiltro();
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      _mostrarErro('Erro ao carregar itens: $e');
    }
  }

  void _aplicarFiltro() {
    if (_filtroPedidoId == null) {
      _itensFiltrados = List.from(_todosItens);
    } else {
      _itensFiltrados = _todosItens
          .where((item) => item.pedidoId == _filtroPedidoId)
          .toList();
    }
  }

  Future<void> _deletar(int id) async {
    try {
      await _repository.deletar(id);
      _carregarTudo();
    } catch (e) {
      _mostrarErro('Erro ao deletar: $e');
    }
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
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
            child: DropdownButtonFormField<int?>(
              value: _filtroPedidoId,
              decoration: const InputDecoration(
                labelText: 'Filtrar por Pedido',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.filter_list),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('Todos os pedidos'),
                ),
                ..._pedidos.map(
                  (p) => DropdownMenuItem<int?>(
                    value: p.id,
                    child: Text('Pedido #${p.id} — ${p.status}'),
                  ),
                ),
              ],
              onChanged: (v) {
                setState(() {
                  _filtroPedidoId = v;
                  _aplicarFiltro();
                });
              },
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _itensFiltrados.isEmpty
                ? const Center(child: Text('Nenhum item encontrado.'))
                : ListView.builder(
                    itemCount: _itensFiltrados.length,
                    itemBuilder: (context, index) {
                      final item = _itensFiltrados[index];
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
                                _carregarTudo();
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
          _carregarTudo();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
