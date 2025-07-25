// lib/controllers/agendamento_controller.dart
import 'package:flutter/material.dart';
import '../dao/agendamentodao.dart';
import '../dto/agendamentodto.dart';

class AgendamentoController extends ChangeNotifier {
  final AgendamentoDAO _dao = AgendamentoDAO();

  List<AgendamentoDTO> _agendamentos = [];
  bool _isLoading = false;
  String? _erro;

  // Getters
  List<AgendamentoDTO> get agendamentos => _agendamentos;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  // Carregar todos os agendamentos
  Future<void> carregarAgendamentos() async {
    _setLoading(true);
    try {
      _agendamentos = await _dao.buscarTodos();
      _erro = null;
    } catch (e) {
      _erro = 'Erro ao carregar agendamentos: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Criar novo agendamento
  Future<bool> criarAgendamento(AgendamentoDTO agendamento) async {
    _setLoading(true);
    try {
      // Verificar disponibilidade
      final disponivel = await _dao.verificarDisponibilidade(
        agendamento.dataInicio,
        agendamento.dataFim,
      );

      if (!disponivel) {
        _erro = 'As datas selecionadas não estão disponíveis';
        return false;
      }

      await _dao.criar(agendamento);
      await carregarAgendamentos(); // Recarrega a lista
      _erro = null;
      return true;
    } catch (e) {
      _erro = 'Erro ao criar agendamento: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar agendamento
  Future<bool> atualizarAgendamento(AgendamentoDTO agendamento) async {
    _setLoading(true);
    try {
      final resultado = await _dao.atualizar(agendamento);
      if (resultado != null) {
        await carregarAgendamentos(); // Recarrega a lista
        _erro = null;
        return true;
      } else {
        _erro = 'Agendamento não encontrado';
        return false;
      }
    } catch (e) {
      _erro = 'Erro ao atualizar agendamento: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar status do agendamento
  Future<bool> atualizarStatus(int id, String novoStatus) async {
    _setLoading(true);
    try {
      final resultado = await _dao.atualizarStatus(id, novoStatus);
      if (resultado != null) {
        await carregarAgendamentos(); // Recarrega a lista
        _erro = null;
        return true;
      } else {
        _erro = 'Agendamento não encontrado';
        return false;
      }
    } catch (e) {
      _erro = 'Erro ao atualizar status: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Excluir agendamento
  Future<bool> excluirAgendamento(int id) async {
    _setLoading(true);
    try {
      final sucesso = await _dao.excluir(id);
      if (sucesso) {
        await carregarAgendamentos(); // Recarrega a lista
        _erro = null;
        return true;
      } else {
        _erro = 'Agendamento não encontrado';
        return false;
      }
    } catch (e) {
      _erro = 'Erro ao excluir agendamento: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Buscar agendamento por ID
  Future<AgendamentoDTO?> buscarPorId(int id) async {
    try {
      return await _dao.buscarPorId(id);
    } catch (e) {
      _erro = 'Erro ao buscar agendamento: $e';
      notifyListeners();
      return null;
    }
  }

  // Filtrar agendamentos por status
  Future<void> filtrarPorStatus(String status) async {
    _setLoading(true);
    try {
      _agendamentos = await _dao.buscarPorStatus(status);
      _erro = null;
    } catch (e) {
      _erro = 'Erro ao filtrar agendamentos: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Verificar disponibilidade de datas
  Future<bool> verificarDisponibilidade(DateTime inicio, DateTime fim,
      {int? idExcluir}) async {
    try {
      return await _dao.verificarDisponibilidade(inicio, fim,
          idExcluir: idExcluir);
    } catch (e) {
      _erro = 'Erro ao verificar disponibilidade: $e';
      notifyListeners();
      return false;
    }
  }

  // Obter estatísticas dos agendamentos
  Future<Map<String, int>> obterEstatisticas() async {
    try {
      return await _dao.contarPorStatus();
    } catch (e) {
      _erro = 'Erro ao obter estatísticas: $e';
      notifyListeners();
      return {};
    }
  }

  // Calcular valor total do agendamento
  double calcularValorTotal(DateTime inicio, DateTime fim, double valorDiaria) {
    final dias = fim.difference(inicio).inDays + 1;
    return dias * valorDiaria;
  }

  // Limpar erro
  void limparErro() {
    _erro = null;
    notifyListeners();
  }

  // Método privado para controlar loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
