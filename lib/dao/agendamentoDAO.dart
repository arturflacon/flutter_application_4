// lib/dao/agendamento_dao.dart
import '../dto/agendamentodto.dart';

class AgendamentoDAO {
  static final AgendamentoDAO _instance = AgendamentoDAO._internal();
  factory AgendamentoDAO() => _instance;
  AgendamentoDAO._internal();

  // Simulação de banco de dados em memória
  final List<AgendamentoDTO> _agendamentos = [
    AgendamentoDTO(
      id: 1,
      nomeCliente: 'João Silva',
      telefone: '(11) 99999-9999',
      email: 'joao@email.com',
      dataInicio: DateTime(2025, 6, 15),
      dataFim: DateTime(2025, 6, 16),
      quantidadePessoas: 20,
      valorTotal: 800.0,
      status: 'Confirmado',
      observacoes: 'Festa de aniversário',
    ),
    AgendamentoDTO(
      id: 2,
      nomeCliente: 'Maria Santos',
      telefone: '(11) 88888-8888',
      email: 'maria@email.com',
      dataInicio: DateTime(2025, 6, 22),
      dataFim: DateTime(2025, 6, 23),
      quantidadePessoas: 15,
      valorTotal: 600.0,
      status: 'Pendente',
      observacoes: 'Reunião familiar',
    ),
    AgendamentoDTO(
      id: 3,
      nomeCliente: 'Pedro Costa',
      telefone: '(11) 77777-7777',
      email: 'pedro@email.com',
      dataInicio: DateTime(2025, 7, 1),
      dataFim: DateTime(2025, 7, 2),
      quantidadePessoas: 30,
      valorTotal: 1000.0,
      status: 'Confirmado',
      observacoes: 'Evento corporativo',
    ),
  ];

  int _nextId = 4;

  // CREATE - Criar novo agendamento
  Future<AgendamentoDTO> criar(AgendamentoDTO agendamento) async {
    final novoAgendamento = agendamento.copyWith(id: _nextId++);
    _agendamentos.add(novoAgendamento);
    return novoAgendamento;
  }

  // READ - Buscar todos os agendamentos
  Future<List<AgendamentoDTO>> buscarTodos() async {
    return List.from(_agendamentos);
  }

  // READ - Buscar agendamento por ID
  Future<AgendamentoDTO?> buscarPorId(int id) async {
    try {
      return _agendamentos.firstWhere((agendamento) => agendamento.id == id);
    } catch (e) {
      return null;
    }
  }

  // READ - Buscar agendamentos por status
  Future<List<AgendamentoDTO>> buscarPorStatus(String status) async {
    return _agendamentos
        .where((agendamento) => agendamento.status == status)
        .toList();
  }

  // READ - Buscar agendamentos por período
  Future<List<AgendamentoDTO>> buscarPorPeriodo(
      DateTime inicio, DateTime fim) async {
    return _agendamentos.where((agendamento) {
      return agendamento.dataInicio
              .isBefore(fim.add(const Duration(days: 1))) &&
          agendamento.dataFim.isAfter(inicio.subtract(const Duration(days: 1)));
    }).toList();
  }

  // UPDATE - Atualizar agendamento
  Future<AgendamentoDTO?> atualizar(AgendamentoDTO agendamento) async {
    final index = _agendamentos.indexWhere((a) => a.id == agendamento.id);
    if (index != -1) {
      _agendamentos[index] = agendamento;
      return agendamento;
    }
    return null;
  }

  // UPDATE - Atualizar status do agendamento
  Future<AgendamentoDTO?> atualizarStatus(int id, String novoStatus) async {
    final agendamento = await buscarPorId(id);
    if (agendamento != null) {
      final agendamentoAtualizado = agendamento.copyWith(status: novoStatus);
      return await atualizar(agendamentoAtualizado);
    }
    return null;
  }

  // DELETE - Excluir agendamento
  Future<bool> excluir(int id) async {
    final index =
        _agendamentos.indexWhere((agendamento) => agendamento.id == id);
    if (index != -1) {
      _agendamentos.removeAt(index);
      return true;
    }
    return false;
  }

  // Verificar disponibilidade de datas
  Future<bool> verificarDisponibilidade(DateTime inicio, DateTime fim,
      {int? idExcluir}) async {
    for (final agendamento in _agendamentos) {
      // Pula o agendamento atual se estiver editando
      if (idExcluir != null && agendamento.id == idExcluir) continue;

      // Verifica se há conflito de datas
      if (agendamento.dataInicio.isBefore(fim.add(const Duration(days: 1))) &&
          agendamento.dataFim
              .isAfter(inicio.subtract(const Duration(days: 1)))) {
        return false;
      }
    }
    return true;
  }

  // Contar agendamentos por status
  Future<Map<String, int>> contarPorStatus() async {
    final contadores = <String, int>{};
    for (final agendamento in _agendamentos) {
      contadores[agendamento.status] =
          (contadores[agendamento.status] ?? 0) + 1;
    }
    return contadores;
  }
}
