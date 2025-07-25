import 'package:flutter/material.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_card.dart';
import '../components/status_chip.dart';
import '../models/agendamento.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';

class AgendamentoDetalhesScreen extends StatefulWidget {
  final Agendamento agendamento;

  const AgendamentoDetalhesScreen({Key? key, required this.agendamento})
      : super(key: key);

  @override
  State<AgendamentoDetalhesScreen> createState() =>
      _AgendamentoDetalhesScreenState();
}

class _AgendamentoDetalhesScreenState extends State<AgendamentoDetalhesScreen> {
  late Agendamento agendamento;

  @override
  void initState() {
    super.initState();
    agendamento = widget.agendamento;
  }

  Future<void> _alterarStatus(String novoStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar alteração'),
        content: Text('Deseja alterar o status para "$novoStatus"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      agendamento.status = novoStatus;
      await DatabaseHelper.instance.updateAgendamento(agendamento);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status atualizado com sucesso!')),
      );
    }
  }

  String _formatPeriodo(String periodo) {
    switch (periodo) {
      case 'manha':
        return 'Manhã (06:00 - 12:00)';
      case 'tarde':
        return 'Tarde (12:00 - 18:00)';
      case 'noite':
        return 'Noite (18:00 - 00:00)';
      case 'dia_todo':
        return 'Dia Todo (06:00 - 00:00)';
      default:
        return periodo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Detalhes do Agendamento'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Informações do Cliente
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    const Text(
                      'Cliente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  agendamento.cliente?.nome ?? 'Cliente não encontrado',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      agendamento.cliente?.telefone ?? '',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Informações do Agendamento
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event, color: Color(0xFF2E7D32)),
                        const SizedBox(width: 8),
                        const Text(
                          'Agendamento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    StatusChip(status: agendamento.status),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Data do Evento',
                  DateFormat('dd/MM/yyyy').format(agendamento.dataEvento),
                  Icons.calendar_today,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Período',
                  _formatPeriodo(agendamento.periodo),
                  Icons.access_time,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Data da Reserva',
                  DateFormat('dd/MM/yyyy HH:mm')
                      .format(agendamento.dataReserva),
                  Icons.event_available,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Valor Total',
                  'R\$ ${agendamento.valorTotal.toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
                if (agendamento.observacoes != null &&
                    agendamento.observacoes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Observações:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    agendamento.observacoes!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Serviços
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.room_service, color: Color(0xFF2E7D32)),
                    const SizedBox(width: 8),
                    const Text(
                      'Serviços',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (agendamento.servicos.isEmpty)
                  const Text(
                    'Nenhum serviço selecionado',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  )
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botões de Ação
          if (agendamento.status != 'cancelado') ...[
            Row(
              children: [
                if (agendamento.status == 'pendente') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _alterarStatus('confirmado'),
                      icon: const Icon(Icons.check),
                      label: const Text('Confirmar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (agendamento.status != 'cancelado')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _alterarStatus('cancelado'),
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
