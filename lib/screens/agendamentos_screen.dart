import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_card.dart';
import '../components/status_chip.dart';
import '../models/agendamento.dart';
import '../database/database_helper.dart';
import 'agendamento_detalhes_screen.dart';

class AgendamentosScreen extends StatefulWidget {
  const AgendamentosScreen({Key? key}) : super(key: key);

  @override
  State<AgendamentosScreen> createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  List<Agendamento> agendamentos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAgendamentos();
  }

  Future<void> _loadAgendamentos() async {
    final agendamentosList = await DatabaseHelper.instance.getAgendamentos();
    setState(() {
      agendamentos = agendamentosList;
      isLoading = false;
    });
  }

  String _formatPeriodo(String periodo) {
    switch (periodo) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Agendamentos'),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : agendamentos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum agendamento encontrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAgendamentos,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: agendamentos.length,
                    itemBuilder: (context, index) {
                      final agendamento = agendamentos[index];
                      return CustomCard(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AgendamentoDetalhesScreen(
                                agendamento: agendamento,
                              ),
                            ),
                          );
                          _loadAgendamentos();
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    agendamento.cliente?.nome ??
                                        'Cliente não encontrado',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                StatusChip(status: agendamento.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('dd/MM/yyyy')
                                      .format(agendamento.dataEvento),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.access_time,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  _formatPeriodo(agendamento.periodo),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  agendamento.cliente?.telefone ?? '',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Serviços: ${agendamento.servicos.length}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  'R\$ ${agendamento.valorTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
