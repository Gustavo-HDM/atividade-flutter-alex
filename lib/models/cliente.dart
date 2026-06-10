class Cliente {
  final int? id;
  final String nome;
  final String email;
  final String? telefone;

  Cliente({this.id, required this.nome, required this.email, this.telefone});

  factory Cliente.fromRow(Map<String, dynamic> row) {
    return Cliente(
      id: row['id'] as int,
      nome: row['nome'] as String,
      email: row['email'] as String,
      telefone: row['telefone'] as String?,
    );
  }
}
