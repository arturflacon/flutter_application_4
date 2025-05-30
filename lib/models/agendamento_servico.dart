class AgendamentoServico {
  int? id;
  int agendamentoId;
  int servicoId;
  int quantidade;
  double precoUnitario;

  AgendamentoServico({
    this.id,
    required this.agendamentoId,
    required this.servicoId,
    required this.quantidade,
    required this.precoUnitario,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'agendamentoId': agendamentoId,
      'servicoId': servicoId,
      'quantidade': quantidade,
      'precoUnitario': precoUnitario,
    };
  }

  factory AgendamentoServico.fromMap(Map<String, dynamic> map) {
    return AgendamentoServico(
      id: map['id']?.toInt(),
      agendamentoId: map['agendamentoId']?.toInt() ?? 0,
      servicoId: map['servicoId']?.toInt() ?? 0,
      quantidade: map['quantidade']?.toInt() ?? 1,
      precoUnitario: map['precoUnitario']?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'AgendamentoServico{id: $id, agendamentoId: $agendamentoId, servicoId: $servicoId, quantidade: $quantidade, precoUnitario: $precoUnitario}';
  }
}
