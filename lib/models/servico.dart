class Servico {
  final int? id;
  final String nome;
  final String descricao;
  final double preco;
  final bool ativo;
  final DateTime dataCriacao;

  Servico({
    this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    this.ativo = true,
    required this.dataCriacao,
  });

  // Converter para Map (para salvar no banco)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'ativo': ativo ? 1 : 0,
      'data_criacao': dataCriacao
          .millisecondsSinceEpoch, // ✅ Agora corresponde à coluna do banco
    };
  }

  // Criar Servico a partir de Map (do banco)
  factory Servico.fromMap(Map<String, dynamic> map) {
    return Servico(
      id: map['id'],
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      preco: (map['preco'] ?? 0.0).toDouble(),
      ativo: (map['ativo'] ?? 1) == 1,
      dataCriacao: DateTime.fromMillisecondsSinceEpoch(
        map['data_criacao'] ??
            DateTime.now()
                .millisecondsSinceEpoch, // ✅ Agora corresponde à coluna do banco
      ),
    );
  }

  // Criar cópia com modificações
  Servico copyWith({
    int? id,
    String? nome,
    String? descricao,
    double? preco,
    bool? ativo,
    DateTime? dataCriacao,
  }) {
    return Servico(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      ativo: ativo ?? this.ativo,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }

  @override
  String toString() {
    return 'Servico{id: $id, nome: $nome, descricao: $descricao, preco: $preco, ativo: $ativo, dataCriacao: $dataCriacao}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Servico &&
        other.id == id &&
        other.nome == nome &&
        other.descricao == descricao &&
        other.preco == preco &&
        other.ativo == ativo &&
        other.dataCriacao == dataCriacao;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nome.hashCode ^
        descricao.hashCode ^
        preco.hashCode ^
        ativo.hashCode ^
        dataCriacao.hashCode;
  }
}
