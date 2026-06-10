import 'package:flutter/material.dart';
import '../../models/cliente.dart';
import '../../repositories/cliente_repository.dart';
import 'cliente_form_screen.dart';

class ClienteListScreen extends StatefulWidget {
  const ClienteListScreen({super.key});

  @override
  State<ClienteListScreen> createState() => _ClienteListScreenState();
}

class _ClienteListScreenState extends State<ClienteListScreen> {
  final _repository = ClienteRepository();
  List<Cliente> _clientes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    setState(() => _carregando = true);
    try {
      final clientes = await _repository.listarTodos();
      setState(() {
        _clientes = clientes;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      _mostrarErro('Erro ao carregar clientes: $e');
    }
  }

  Future<void> _deletar(int id) async {
    try {
      await _repository.deletar(id);
      _carregarClientes();
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
        title: const Text('Clientes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _clientes.isEmpty
          ? const Center(child: Text('Nenhum cliente cadastrado.'))
          : ListView.builder(
              itemCount: _clientes.length,
              itemBuilder: (context, index) {
                final c = _clientes[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(c.nome),
                  subtitle: Text(c.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClienteFormScreen(cliente: c),
                            ),
                          );
                          _carregarClientes();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletar(c.id!),
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
            MaterialPageRoute(builder: (_) => const ClienteFormScreen()),
          );
          _carregarClientes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
