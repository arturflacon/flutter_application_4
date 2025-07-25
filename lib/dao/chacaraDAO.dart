// lib/dao/chacara_dao.dart
import '../dto/chacaradto.dart';

class ChacaraDAO {
  static final ChacaraDAO _instance = ChacaraDAO._internal();
  factory ChacaraDAO() => _instance;
  ChacaraDAO._internal();

  // Dados da chácara (normalmente viria de um banco de dados)
  final ChacaraDTO _chacara = ChacaraDTO(
    nome: 'Chácara Nossa Senhora De Lurdes',
    endereco: 'Frente aos 3 Morrinhos',
    cidade: 'Terra Rica - PR',
    capacidadeMaxima: 50,
    valorDiaria: 450.0,
    comodidades: [
      'Piscina',
      'Churrasqueira',
      'Salão de festas',
      'Riacho',
      'Área verde',
      'Estacionamento'
    ],
  );

  // Buscar informações da chácara
  Future<ChacaraDTO> buscarInformacoes() async {
    return _chacara;
  }

  // Atualizar informações da chácara (para futuras implementações)
  Future<ChacaraDTO> atualizar(ChacaraDTO novaChacara) async {
    // Em uma implementação real, isso salvaria no banco de dados
    // Por enquanto, retorna as informações atuais
    return _chacara;
  }
}
