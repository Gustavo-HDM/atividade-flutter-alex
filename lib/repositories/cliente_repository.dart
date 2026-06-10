import 'package:postgres/postgres.dart';

import '../database/db_connection.dart';
import '../models/cliente.dart';

class ClienteRepository {
  Future<void> inserir(Cliente c) async {
    final conn = await DBConnection.getConnection();
    await conn.execute(
      Sql.named('INSERT INTO cliente (nome, email, telefone) '
          'VALUES (@nome, @email, @telefone)'),
      parameters: {
        'nome': c.nome,
        'email': c.email,
        'telefone': c.telefone,
      },
    );
  }


  Future<List<Cliente>> listarTodos() async {
    final conn = await DBConnection.getConnection();
    final result = await conn.execute('SELECT * FROM cliente ORDER BY id');
    return result.map((row) => Cliente.fromRow(row.toColumnMap())).toList();
  }

  Future<void> atualizar(Cliente c) async {
    final conn = await DBConnection.getConnection();
    await conn.execute(
      Sql.named('UPDATE cliente SET nome=@nome, email=@email, '
          'telefone=@telefone WHERE id=@id'),
      parameters: {
        'nome': c.nome,
        'email': c.email,
        'telefone': c.telefone,
        'id': c.id,
      },
    );
  }

  Future<void> deletar(int id) async {
    final conn = await DBConnection.getConnection();
    await conn.execute(
      Sql.named('DELETE FROM cliente WHERE id=@id'),
      parameters: {'id': id},
    );
  }
}