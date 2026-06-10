import 'package:flutter/material.dart';
import '../../models/produto.dart';
import '../../repositories/produto_repository.dart';
import 'produto_form_screen.dart';

class ProdutoListScreen extends StatefulWidget {
  const ProdutoListScreen({super.key});

  @override
  State<ProdutoListScreen> createState() => _ProdutoListScreenState();
}

class _ProdutoListScreenState extends State<ProdutoListScreen> {
  final _repository = ProdutoRepository();
  List<Produto> _produtos = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    setState(() => _carregando = true);
    try {
      final produtos = await _repository.listarTodos();
      setState(() {
        _produtos = produtos;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      _mostrarErro('Erro ao carregar produtos: $e');
    }
  }

  Future<void> _deletar(int id) async {
    try {
      await _repository.deletar(id);
      _carregarProdutos();
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
        title: const Text('Produtos'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _produtos.isEmpty
          ? const Center(child: Text('Nenhum produto cadastrado.'))
          : ListView.builder(
              itemCount: _produtos.length,
              itemBuilder: (context, index) {
                final p = _produtos[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.shopping_bag, color: Colors.white),
                  ),
                  title: Text(p.nome),
                  subtitle: Text(
                    'R\$ ${p.preco.toStringAsFixed(2)} | Estoque: ${p.estoque}',
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
                              builder: (_) => ProdutoFormScreen(produto: p),
                            ),
                          );
                          _carregarProdutos();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletar(p.id!),
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
            MaterialPageRoute(builder: (_) => const ProdutoFormScreen()),
          );
          _carregarProdutos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
