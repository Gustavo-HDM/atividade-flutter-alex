import 'package:flutter/material.dart';
import '../../models/pedido.dart';
import '../../models/pedido_produto.dart';
import '../../models/cliente.dart';
import '../../models/produto.dart';
import '../../repositories/pedido_repository.dart';
import '../../repositories/pedido_produto_repository.dart';
import '../../repositories/cliente_repository.dart';
import '../../repositories/produto_repository.dart';

class PedidoFormScreen extends StatefulWidget {
  final Pedido? pedido;

  const PedidoFormScreen({super.key, this.pedido});

  @override
  State<PedidoFormScreen> createState() => _PedidoFormScreenState();
}

class _PedidoFormScreenState extends State<PedidoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pedidoRepository = PedidoRepository();
  final _itemRepository = PedidoProdutoRepository();
  final _clienteRepository = ClienteRepository();
  final _produtoRepository = ProdutoRepository();

  List<Cliente> _clientes = [];
  List<Produto> _produtos = [];
  List<_ItemTemp> _itens = [];

  int? _clienteSelecionado;
  String _status = 'aberto';
  bool _salvando = false;
  bool _carregando = true;

  bool get _editando => widget.pedido != null;

  final List<String> _statusOpcoes = ['aberto', 'fechado', 'cancelado'];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final clientes = await _clienteRepository.listarTodos();
      final produtos = await _produtoRepository.listarTodos();
      setState(() {
        _clientes = clientes;
        _produtos = produtos;
        _carregando = false;
        if (_editando) {
          _clienteSelecionado = widget.pedido!.clienteId;
          _status = widget.pedido!.status;
        }
      });

      if (_editando) {
        final itensExistentes = await _itemRepository.listarPorPedido(
          widget.pedido!.id!,
        );
        setState(() {
          _itens = itensExistentes
              .map(
                (i) => _ItemTemp(
                  produtoId: i.produtoId,
                  quantidade: i.quantidade,
                  precoUnit: i.precoUnit,
                  itemId: i.id,
                ),
              )
              .toList();
        });
      }
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

  void _adicionarItem() {
    showDialog(
      context: context,
      builder: (context) {
        int? produtoSelecionado;
        final qtdController = TextEditingController(text: '1');
        final precoController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Adicionar Produto'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    value: produtoSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Produto *',
                      border: OutlineInputBorder(),
                    ),
                    items: _produtos
                        .map(
                          (p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(
                              '${p.nome} — R\$ ${p.preco.toStringAsFixed(2)}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setStateDialog(() {
                        produtoSelecionado = v;
                        final produto = _produtos.firstWhere((p) => p.id == v);
                        precoController.text = produto.preco.toStringAsFixed(2);
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: qtdController,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: precoController,
                    decoration: const InputDecoration(
                      labelText: 'Preço Unitário *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (produtoSelecionado == null) return;
                    final qtd = int.tryParse(qtdController.text) ?? 1;
                    final preco =
                        double.tryParse(
                          precoController.text.replaceAll(',', '.'),
                        ) ??
                        0.0;
                    setState(() {
                      _itens.add(
                        _ItemTemp(
                          produtoId: produtoSelecionado!,
                          quantidade: qtd,
                          precoUnit: preco,
                        ),
                      );
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double get _total => _itens.fold(
    0.0,
    (soma, item) => soma + (item.precoUnit * item.quantidade),
  );

  String _nomeProduto(int id) {
    try {
      return _produtos.firstWhere((p) => p.id == id).nome;
    } catch (_) {
      return 'Produto #$id';
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um cliente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos um produto'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _salvando = true);

    try {
      int pedidoId;

      if (_editando) {
        final pedido = Pedido(
          id: widget.pedido!.id,
          clienteId: _clienteSelecionado!,
          status: _status,
        );
        await _pedidoRepository.atualizar(pedido);
        pedidoId = widget.pedido!.id!;

        // Deleta itens antigos e reinsere
        for (final item in _itens.where((i) => i.itemId != null)) {
          await _itemRepository.deletar(item.itemId!);
        }
      } else {
        final pedido = Pedido(clienteId: _clienteSelecionado!, status: _status);
        await _pedidoRepository.inserir(pedido);

        // Busca o ID do pedido recém criado
        final pedidos = await _pedidoRepository.listarTodos();
        pedidoId = pedidos.last.id!;
      }

      // Insere todos os itens
      for (final item in _itens) {
        await _itemRepository.inserir(
          PedidoProduto(
            pedidoId: pedidoId,
            produtoId: item.produtoId,
            quantidade: item.quantidade,
            precoUnit: item.precoUnit,
          ),
        );
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
        title: Text(_editando ? 'Editar Pedido' : 'Novo Pedido'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Cliente
                  DropdownButtonFormField<int>(
                    value: _clienteSelecionado,
                    decoration: const InputDecoration(
                      labelText: 'Cliente *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: _clientes
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.nome),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _clienteSelecionado = v),
                    validator: (v) => v == null ? 'Selecione um cliente' : null,
                  ),
                  const SizedBox(height: 16),

                  // Status
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag),
                    ),
                    items: _statusOpcoes
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                  const SizedBox(height: 24),

                  // Produtos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Produtos do Pedido',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _adicionarItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Lista de itens
                  if (_itens.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Nenhum produto adicionado ainda.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ..._itens.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Icon(
                              Icons.shopping_bag,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(_nomeProduto(item.produtoId)),
                          subtitle: Text('Qtd: ${item.quantidade}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'R\$ ${(item.precoUnit * item.quantidade).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    setState(() => _itens.removeAt(index)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  const Divider(height: 32),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$ ${_total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botão salvar
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _salvando ? null : _salvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: _salvando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _editando
                                  ? 'Salvar Alterações'
                                  : 'Cadastrar Pedido',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// Classe auxiliar para itens temporários antes de salvar
class _ItemTemp {
  final int produtoId;
  final int quantidade;
  final double precoUnit;
  final int? itemId;

  _ItemTemp({
    required this.produtoId,
    required this.quantidade,
    required this.precoUnit,
    this.itemId,
  });
}
