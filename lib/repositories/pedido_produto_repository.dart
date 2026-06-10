import 'package:postgres/postgres.dart';
import '../database/db_connection.dart';
import '../models/pedido_produto.dart';

class PedidoProdutoRepository {
  Future<void> inserir(PedidoProduto pp) async {
    final conn = await DBConnection.getConnection();
    await conn.execute(
      Sql.named(
        'INSERT INTO pedido_produto (pedido_id, produto_id, quantidade, preco_unit) '
        'VALUES (@pedido_id, @produto_id, @quantidade, @preco_unit)',
      ),
      parameters: {
        'pedido_id': pp.pedidoId,
        'produto_id': pp.produtoId,
        'quantidade': pp.quantidade,
        'preco_unit': pp.precoUnit,
      },
    );
  }

  Future<List<PedidoProduto>> listarPorPedido(int pedidoId) async {
    final conn = await DBConnection.getConnection();
    final result = await conn.execute(
      Sql.named('SELECT * FROM pedido_produto WHERE pedido_id=@pedido_id'),
      parameters: {'pedido_id': pedidoId},
    );
    return result
        .map((row) => PedidoProduto.fromRow(row.toColumnMap()))
        .toList();
  }

  Future<void> atualizar(PedidoProduto pp) async {
    final conn = await DBConnection.getConnection();
    await conn.execute(
      Sql.named(
        'UPDATE pedido_produto SET quantidade=@quantidade, '
        'preco_unit=@preco_unit WHERE id=@id',
      ),
      parameters: {
        'quantidade': pp.quantidade,
        'preco_unit': pp.precoUnit,
        'id': pp.id,
      },
    );
  }

  Future<void> deletar(int id) async {
    final conn = await DBConnection.getConnection();
    await conn.execute(
      Sql.named('DELETE FROM pedido_produto WHERE id=@id'),
      parameters: {'id': id},
    );
  }
}
