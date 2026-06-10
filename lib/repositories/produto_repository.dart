import 'package:postgres/postgres.dart';
import '../database/db_connection.dart';
import '../models/produto.dart';

class ProdutoRepository {
  Future<void> inserir(Produto p) async {
    final conn = await DBConnection.getConnection();
    await conn.execute(
      Sql.named(
        'INSERT INTO produto (nome, preco, estoque) '
        'VALUES (@nome, @preco, @estoque)',
      ),
      parameters: {'nome': p.nome, 'preco': p.preco, 'estoque': p.estoque},
    );
  }

  Future<List<Produto>> listarTodos() async {
    final conn = await DBConnection.getConnection();
    final result = await conn.execute('SELECT * FROM produto ORDER BY id');
    return result.map((row) => Produto.fromRow(row.toColumnMap())).toList();
  }

  Future<void> atualizar(Produto p) async {
    final conn = await DBConnection.getConnection();
    await conn.execute(
      Sql.named(
        'UPDATE produto SET nome=@nome, preco=@preco, '
        'estoque=@estoque WHERE id=@id',
      ),
      parameters: {
        'nome': p.nome,
        'preco': p.preco,
        'estoque': p.estoque,
        'id': p.id,
      },
    );
  }

  Future<void> deletar(int id) async {
    final conn = await DBConnection.getConnection();
    await conn.execute(
      Sql.named('DELETE FROM produto WHERE id=@id'),
      parameters: {'id': id},
    );
  }
}
