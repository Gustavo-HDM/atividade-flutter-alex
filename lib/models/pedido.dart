class Pedido {
  final int? id;
  final int clienteId;
  final DateTime? dataPedido;
  final String status;

  Pedido({
    this.id,
    required this.clienteId,
    this.dataPedido,
    this.status = 'aberto',
  });

  factory Pedido.fromRow(Map<String, dynamic> row) {
    return Pedido(
      id: row['id'] as int,
      clienteId: row['cliente_id'] as int,
      dataPedido: row['data_pedido'] as DateTime?,
      status: row['status'] as String,
    );
  }
}
