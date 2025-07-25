// lib/controllers/chacara_controller.dart
import 'package:flutter/material.dart';
import '../dao/chacaradao.dart';
import '../dto/chacaradto.dart';

class ChacaraController extends ChangeNotifier {
  final ChacaraDAO _dao = ChacaraDAO();

  ChacaraDTO? _chacara;
  bool _isLoading = false;
  String? _erro;

  // Getters
  ChacaraDTO? get chacara => _chacara;
  bool get isLoading => _isLoading;
  String? get erro => _erro;

  // Carregar informações da chácara
  Future<void> carregarInformacoes() async {
    _setLoading(true);
    try {
      _chacara = await _dao.buscarInformacoes();
      _erro = null;
    } catch (e) {
      _erro = 'Erro ao carregar informações da chácara: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Atualizar informações da chácara
  Future<bool> atualizarInformacoes(ChacaraDTO novaChacara) async {
    _setLoading(true);
    try {
      _chacara = await _dao.atualizar(novaChacara);
      _erro = null;
      return true;
    } catch (e) {
      _erro = 'Erro ao atualizar informações: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Verificar se a quantidade de pessoas está dentro da capacidade
  bool verificarCapacidade(int quantidadePessoas) {
    if (_chacara == null) return false;
    return quantidadePessoas <= _chacara!.capacidadeMaxima;
  }

  // Obter valor da diária
  double get valorDiaria => _chacara?.valorDiaria ?? 0.0;

  // Obter capacidade máxima
  int get capacidadeMaxima => _chacara?.capacidadeMaxima ?? 0;

  // Obter comodidades
  List<String> get comodidades => _chacara?.comodidades ?? [];

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
