import 'package:postgres/postgres.dart';
import '../database/db_connection.dart';
import '../models/pedido.dart';

class PedidoRepository {
  Future<void> inserir(Pedido p) async {
    final conn = await DBConnection.getConnection();
    await conn.execute(
      Sql.named(
        'INSERT INTO pedido (cliente_id, status) '
        'VALUES (@cliente_id, @status)',
      ),
      parameters: {'cliente_id': p.clienteId, 'status': p.status},
    );
  }

  Future<List<Pedido>> listarTodos() async {
    final conn = await DBConnection.getConnection();
    final result = await conn.execute('SELECT * FROM pedido ORDER BY id');
    return result.map((row) => Pedido.fromRow(row.toColumnMap())).toList();
  }

  Future<void> atualizar(Pedido p) async {
    final conn = await DBConnection.getConnection();
    await conn.execute(
      Sql.named(
        'UPDATE pedido SET cliente_id=@cliente_id, '
        'status=@status WHERE id=@id',
      ),
      parameters: {'cliente_id': p.clienteId, 'status': p.status, 'id': p.id},
    );
  }

  Future<void> deletar(int id) async {
    final conn = await DBConnection.getConnection();
    await conn.execute(
      Sql.named('DELETE FROM pedido WHERE id=@id'),
      parameters: {'id': id},
    );
  }
}
