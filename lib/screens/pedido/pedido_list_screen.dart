import 'package:flutter/material.dart';
import '../../models/pedido.dart';
import '../../models/pedido_produto.dart';
import '../../repositories/pedido_repository.dart';
import '../../repositories/pedido_produto_repository.dart';
import 'pedido_form_screen.dart';

class PedidoListScreen extends StatefulWidget {
  const PedidoListScreen({super.key});

  @override
  State<PedidoListScreen> createState() => _PedidoListScreenState();
}

class _PedidoListScreenState extends State<PedidoListScreen> {
  final _pedidoRepository = PedidoRepository();
  final _itemRepository = PedidoProdutoRepository();
  List<Pedido> _pedidos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  Future<void> _carregarPedidos() async {
    setState(() => _carregando = true);
    try {
      final pedidos = await _pedidoRepository.listarTodos();
      setState(() {
        _pedidos = pedidos;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      _mostrarErro('Erro ao carregar pedidos: $e');
    }
  }

  Future<void> _deletar(int id) async {
    try {
      await _pedidoRepository.deletar(id);
      _carregarPedidos();
    } catch (e) {
      _mostrarErro('Erro ao deletar: $e');
    }
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Color _corStatus(String status) {
    switch (status) {
      case 'aberto':
        return Colors.blue;
      case 'fechado':
        return Colors.green;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /*Future<double> _calcularTotal(int pedidoId) async {
    final itens = await _itemRepository.listarPorPedido(pedidoId);
    return itens.fold<double>(
      0.0,
      (soma, item) => soma + (item.precoUnit * item.quantidade),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _pedidos.isEmpty
          ? const Center(child: Text('Nenhum pedido cadastrado.'))
          : ListView.builder(
              itemCount: _pedidos.length,
              itemBuilder: (context, index) {
                final p = _pedidos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ExpansionTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.receipt, color: Colors.white),
                    ),
                    title: Text(
                      'Pedido #${p.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        Chip(
                          label: Text(
                            p.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                          backgroundColor: _corStatus(p.status),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PedidoFormScreen(pedido: p),
                              ),
                            );
                            _carregarPedidos();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletar(p.id!),
                        ),
                      ],
                    ),
                    children: [
                      FutureBuilder<List<PedidoProduto>>(
                        future: _itemRepository.listarPorPedido(p.id!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            );
                          }
                          final itens = snapshot.data ?? [];
                          final total = itens.fold(
                            0.0,
                            (soma, item) =>
                                soma + (item.precoUnit * item.quantidade),
                          );
                          return Column(
                            children: [
                              const Divider(),
                              ...itens.map(
                                (item) => ListTile(
                                  dense: true,
                                  leading: const Icon(
                                    Icons.shopping_bag,
                                    color: Colors.orange,
                                  ),
                                  title: Text('Produto #${item.produtoId}'),
                                  subtitle: Text('Qtd: ${item.quantidade}'),
                                  trailing: Text(
                                    'R\$ ${(item.precoUnit * item.quantidade).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              if (itens.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Text('Nenhum item neste pedido.'),
                                ),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      'R\$ ${total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PedidoFormScreen()),
          );
          _carregarPedidos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
