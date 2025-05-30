import 'cliente.dart';
import 'servico.dart';

class Agendamento {
  int? id;
  int clienteId;
  DateTime dataReserva;
  DateTime dataEvento;
  String periodo; // manhã, tarde, noite, dia_todo
  double valorTotal;
  String status; // pendente, confirmado, cancelado
  String? observacoes;
  Cliente? cliente;
  List<Servico> servicos;

  Agendamento({
    this.id,
    required this.clienteId,
    required this.dataReserva,
    required this.dataEvento,
    required this.periodo,
    required this.valorTotal,
    this.status = 'pendente',
    this.observacoes,
    this.cliente,
    this.servicos = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clienteId': clienteId,
      'dataReserva': dataReserva.millisecondsSinceEpoch,
      'dataEvento': dataEvento.millisecondsSinceEpoch,
      'periodo': periodo,
      'valorTotal': valorTotal,
      'status': status,
      'observacoes': observacoes,
    };
  }

  factory Agendamento.fromMap(Map<String, dynamic> map) {
    return Agendamento(
      id: map['id']?.toInt(),
      clienteId: map['clienteId']?.toInt() ?? 0,
      dataReserva: DateTime.fromMillisecondsSinceEpoch(
        map['dataReserva']?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
      dataEvento: DateTime.fromMillisecondsSinceEpoch(
        map['dataEvento']?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      ),
      periodo: map['periodo'] ?? '',
      valorTotal: map['valorTotal']?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pendente',
      observacoes: map['observacoes'],
    );
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'pendente':
        return 'Pendente';
      case 'confirmado':
        return 'Confirmado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }

  String get periodoDisplay {
    switch (periodo.toLowerCase()) {
      case 'manha':
        return 'Manhã';
      case 'tarde':
        return 'Tarde';
      case 'noite':
        return 'Noite';
      case 'dia_todo':
        return 'Dia Todo';
      default:
        return periodo;
    }
  }

  @override
  String toString() {
    return 'Agendamento{id: $id, clienteId: $clienteId, dataEvento: $dataEvento, periodo: $periodo, status: $status}';
  }
}
