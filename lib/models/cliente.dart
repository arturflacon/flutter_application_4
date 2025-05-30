class Cliente {
  int? id;
  String nome;
  String telefone;
  String email;
  String cpf;
  DateTime dataCadastro;

  Cliente({
    this.id,
    required this.nome,
    required this.telefone,
    required this.email,
    required this.cpf,
    required this.dataCadastro,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'cpf': cpf,
      'dataCadastro': dataCadastro.millisecondsSinceEpoch,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      id: map['id']?.toInt(),
      nome: map['nome'] ?? '',
      telefone: map['telefone'] ?? '',
      email: map['email'] ?? '',
      cpf: map['cpf'] ?? '',
      dataCadastro: DateTime.fromMillisecondsSinceEpoch(
        map['dataCadastro']?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  String toString() {
    return 'Cliente{id: $id, nome: $nome, telefone: $telefone, email: $email, cpf: $cpf}';
  }
}
