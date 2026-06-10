class PedidoProduto {
  final int? id;
  final int pedidoId;
  final int produtoId;
  final int quantidade;
  final double precoUnit;

  PedidoProduto({
    this.id,
    required this.pedidoId,
    required this.produtoId,
    required this.quantidade,
    required this.precoUnit,
  });

  factory PedidoProduto.fromRow(Map<String, dynamic> row) {
    return PedidoProduto(
      id: row['id'] as int,
      pedidoId: row['pedido_id'] as int,
      produtoId: row['produto_id'] as int,
      quantidade: row['quantidade'] as int,
      precoUnit: double.parse(row['preco_unit'].toString()),
    );
  }
}