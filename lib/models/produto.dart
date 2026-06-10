class Produto {
  final int? id;
  final String nome;
  final double preco;
  final int estoque;

  Produto({
    this.id,
    required this.nome,
    required this.preco,
    required this.estoque,
  });

  factory Produto.fromRow(Map<String, dynamic> row) {
    return Produto(
      id: row['id'] as int,
      nome: row['nome'] as String,
      preco: double.parse(row['preco'].toString()),
      estoque: row['estoque'] as int,
    );
  }
}
