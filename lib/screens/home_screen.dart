import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Compras'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _menuCard(
              context,
              icone: Icons.person,
              titulo: 'Clientes',
              cor: Colors.blue,
              rota: '/clientes',
            ),
            const SizedBox(height: 12),
            _menuCard(
              context,
              icone: Icons.shopping_bag,
              titulo: 'Produtos',
              cor: Colors.green,
              rota: '/produtos',
            ),
            const SizedBox(height: 12),
            _menuCard(
              context,
              icone: Icons.receipt,
              titulo: 'Pedidos',
              cor: Colors.orange,
              rota: '/pedidos',
            ),
            const SizedBox(height: 12),
            _menuCard(
              context,
              icone: Icons.list_alt,
              titulo: 'Itens de Pedido',
              cor: Colors.purple,
              rota: '/pedido-produtos',
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    required Color cor,
    required String rota,
  }) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cor,
          child: Icon(icone, color: Colors.white),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, rota),
      ),
    );
  }
}
