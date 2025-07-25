// lib/dto/chacara_dto.dart
class ChacaraDTO {
  final String nome;
  final String endereco;
  final String cidade;
  final int capacidadeMaxima;
  final double valorDiaria;
  final List<String> comodidades;

  ChacaraDTO({
    required this.nome,
    required this.endereco,
    required this.cidade,
    required this.capacidadeMaxima,
    required this.valorDiaria,
    required this.comodidades,
  });

  // Converte DTO para Map
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'endereco': endereco,
      'cidade': cidade,
      'capacidadeMaxima': capacidadeMaxima,
      'valorDiaria': valorDiaria,
      'comodidades': comodidades,
    };
  }

  // Cria DTO a partir de Map
  factory ChacaraDTO.fromMap(Map<String, dynamic> map) {
    return ChacaraDTO(
      nome: map['nome'] ?? '',
      endereco: map['endereco'] ?? '',
      cidade: map['cidade'] ?? '',
      capacidadeMaxima: map['capacidadeMaxima']?.toInt() ?? 0,
      valorDiaria: map['valorDiaria']?.toDouble() ?? 0.0,
      comodidades: List<String>.from(map['comodidades'] ?? []),
    );
  }

  @override
  String toString() {
    return 'ChacaraDTO(nome: $nome, endereco: $endereco, cidade: $cidade, capacidadeMaxima: $capacidadeMaxima, valorDiaria: $valorDiaria, comodidades: $comodidades)';
  }
}
