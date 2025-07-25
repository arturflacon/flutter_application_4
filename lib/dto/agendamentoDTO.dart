// lib/dto/agendamento_dto.dart
class AgendamentoDTO {
  final int? id;
  final String nomeCliente;
  final String telefone;
  final String? email;
  final DateTime dataInicio;
  final DateTime dataFim;
  final int quantidadePessoas;
  final double valorTotal;
  final String status;
  final String? observacoes;

  AgendamentoDTO({
    this.id,
    required this.nomeCliente,
    required this.telefone,
    this.email,
    required this.dataInicio,
    required this.dataFim,
    required this.quantidadePessoas,
    required this.valorTotal,
    required this.status,
    this.observacoes,
  });

  // Converte DTO para Map (para persistência)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomeCliente': nomeCliente,
      'telefone': telefone,
      'email': email,
      'dataInicio': dataInicio.millisecondsSinceEpoch,
      'dataFim': dataFim.millisecondsSinceEpoch,
      'quantidadePessoas': quantidadePessoas,
      'valorTotal': valorTotal,
      'status': status,
      'observacoes': observacoes,
    };
  }

  // Cria DTO a partir de Map
  factory AgendamentoDTO.fromMap(Map<String, dynamic> map) {
    return AgendamentoDTO(
      id: map['id']?.toInt(),
      nomeCliente: map['nomeCliente'] ?? '',
      telefone: map['telefone'] ?? '',
      email: map['email'],
      dataInicio:
          DateTime.fromMillisecondsSinceEpoch(map['dataInicio']?.toInt() ?? 0),
      dataFim:
          DateTime.fromMillisecondsSinceEpoch(map['dataFim']?.toInt() ?? 0),
      quantidadePessoas: map['quantidadePessoas']?.toInt() ?? 0,
      valorTotal: map['valorTotal']?.toDouble() ?? 0.0,
      status: map['status'] ?? '',
      observacoes: map['observacoes'],
    );
  }

  // Copia o DTO com novos valores
  AgendamentoDTO copyWith({
    int? id,
    String? nomeCliente,
    String? telefone,
    String? email,
    DateTime? dataInicio,
    DateTime? dataFim,
    int? quantidadePessoas,
    double? valorTotal,
    String? status,
    String? observacoes,
  }) {
    return AgendamentoDTO(
      id: id ?? this.id,
      nomeCliente: nomeCliente ?? this.nomeCliente,
      telefone: telefone ?? this.telefone,
      email: email ?? this.email,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      quantidadePessoas: quantidadePessoas ?? this.quantidadePessoas,
      valorTotal: valorTotal ?? this.valorTotal,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  @override
  String toString() {
    return 'AgendamentoDTO(id: $id, nomeCliente: $nomeCliente, telefone: $telefone, email: $email, dataInicio: $dataInicio, dataFim: $dataFim, quantidadePessoas: $quantidadePessoas, valorTotal: $valorTotal, status: $status, observacoes: $observacoes)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AgendamentoDTO && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
