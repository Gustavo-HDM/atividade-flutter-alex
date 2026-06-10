import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/cliente/cliente_list_screen.dart';
import 'screens/produto/produto_list_screen.dart';
import 'screens/pedido/pedido_list_screen.dart';
import 'screens/pedido_produto/pedido_produto_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Compras',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/clientes': (context) => const ClienteListScreen(),
        '/produtos': (context) => const ProdutoListScreen(),
        '/pedidos': (context) => const PedidoListScreen(),
        '/pedido-produtos': (context) => const PedidoProdutoListScreen(),
      },
    );
  }
}