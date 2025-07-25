// lib/views/agendamentos_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/agendamentocontroller.dart';
import '../utils/dateformatter.dart';
import '../utils/statushelper.dart';

class AgendamentosView extends StatefulWidget {
  const AgendamentosView({super.key});

  @override
  State<AgendamentosView> createState() => _AgendamentosViewState();
}

class _AgendamentosViewState extends State<AgendamentosView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AgendamentoController>().carregarAgendamentos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              final result =
                  await Navigator.pushNamed(context, '/novo-agendamento');
              if (result == true) {
                context.read<AgendamentoController>().carregarAgendamentos();
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<AgendamentoController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.erro != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Erro: ${controller.erro}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      controller.limparErro();
                      controller.carregarAgendamentos();
                    },
                    child: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            );
          }

          final agendamentos = controller.agendamentos;

          if (agendamentos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Nenhum agendamento encontrado'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: agendamentos.length,
            itemBuilder: (context, index) {
              final agendamento = agendamentos[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16.0),
                  leading: CircleAvatar(
                    backgroundColor:
                        StatusHelper.getStatusColor(agendamento.status),
                    child: Text(
                      agendamento.nomeCliente[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    agendamento.nomeCliente,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormatter.formatDate(agendamento.dataInicio)} - ${DateFormatter.formatDate(agendamento.dataFim)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('${agendamento.quantidadePessoas} pessoas'),
                          const SizedBox(width: 16),
                          Icon(Icons.attach_money,
                              size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                              'R\$ ${agendamento.valorTotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color:
                              StatusHelper.getStatusColor(agendamento.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          agendamento.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      '/detalhes-agendamento',
                      arguments: agendamento,
                    );
                    if (result == true) {
                      controller.carregarAgendamentos();
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
