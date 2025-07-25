// lib/views/detalhes_agendamento_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/agendamentocontroller.dart';
import '../dto/agendamentodto.dart';
import '../utils/dateformatter.dart';
import '../utils/statushelper.dart';

class DetalhesAgendamentoView extends StatefulWidget {
  const DetalhesAgendamentoView({super.key});

  @override
  State<DetalhesAgendamentoView> createState() =>
      _DetalhesAgendamentoViewState();
}

class _DetalhesAgendamentoViewState extends State<DetalhesAgendamentoView> {
  @override
  Widget build(BuildContext context) {
    final agendamento =
        ModalRoute.of(context)!.settings.arguments as AgendamentoDTO;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Agendamento'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'editar') {
                _mostrarDialogoEdicao(context, agendamento);
              } else if (value == 'excluir') {
                _mostrarDialogoExclusao(context, agendamento);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'editar',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Editar Status'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'excluir',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Excluir', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AgendamentoController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                StatusHelper.getStatusColor(agendamento.status),
                            radius: 30,
                            child: Text(
                              agendamento.nomeCliente[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  agendamento.nomeCliente,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: StatusHelper.getStatusColor(
                                        agendamento.status),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    agendamento.status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informações de Contato',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                          Icons.phone, 'Telefone', agendamento.telefone),
                      if (agendamento.email != null)
                        _buildInfoRow(
                            Icons.email, 'E-mail', agendamento.email!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detalhes do Agendamento',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Data início',
                        DateFormatter.formatDate(agendamento.dataInicio),
                      ),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Data fim',
                        DateFormatter.formatDate(agendamento.dataFim),
                      ),
                      _buildInfoRow(
                        Icons.people,
                        'Pessoas',
                        '${agendamento.quantidadePessoas} pessoas',
                      ),
                      _buildInfoRow(
                        Icons.attach_money,
                        'Valor total',
                        'R\$ ${agendamento.valorTotal.toStringAsFixed(2)}',
                      ),
                      if (agendamento.observacoes != null)
                        _buildInfoRow(Icons.notes, 'Observações',
                            agendamento.observacoes!),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green[600], size: 20),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoEdicao(BuildContext context, AgendamentoDTO agendamento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(
                  backgroundColor: Colors.orange, radius: 10),
              title: const Text('Pendente'),
              onTap: () => _alterarStatus(context, agendamento, 'Pendente'),
            ),
            ListTile(
              leading:
                  const CircleAvatar(backgroundColor: Colors.green, radius: 10),
              title: const Text('Confirmado'),
              onTap: () => _alterarStatus(context, agendamento, 'Confirmado'),
            ),
            ListTile(
              leading:
                  const CircleAvatar(backgroundColor: Colors.red, radius: 10),
              title: const Text('Cancelado'),
              onTap: () => _alterarStatus(context, agendamento, 'Cancelado'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _alterarStatus(BuildContext context, AgendamentoDTO agendamento,
      String novoStatus) async {
    Navigator.pop(context); // Fecha o diálogo

    final controller = context.read<AgendamentoController>();
    final sucesso =
        await controller.atualizarStatus(agendamento.id!, novoStatus);

    if (sucesso) {
      Navigator.pop(context, true); // Volta para a lista
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status alterado para $novoStatus')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.erro ?? 'Erro ao alterar status')),
      );
    }
  }

  void _mostrarDialogoExclusao(
      BuildContext context, AgendamentoDTO agendamento) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
            'Deseja realmente excluir o agendamento de ${agendamento.nomeCliente}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => _excluirAgendamento(context, agendamento),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _excluirAgendamento(
      BuildContext context, AgendamentoDTO agendamento) async {
    Navigator.pop(context); // Fecha o diálogo

    final controller = context.read<AgendamentoController>();
    final sucesso = await controller.excluirAgendamento(agendamento.id!);

    if (sucesso) {
      Navigator.pop(context, true); // Volta para a lista
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento excluído com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(controller.erro ?? 'Erro ao excluir agendamento')),
      );
    }
  }
}
