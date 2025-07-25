// lib/views/novo_agendamento_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/agendamentocontroller.dart';
import '../controllers/chacaracontroller.dart';
import '../dto/agendamentodto.dart';

class NovoAgendamentoView extends StatefulWidget {
  const NovoAgendamentoView({super.key});

  @override
  State<NovoAgendamentoView> createState() => _NovoAgendamentoViewState();
}

class _NovoAgendamentoViewState extends State<NovoAgendamentoView> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _pessoasController = TextEditingController();
  final _observacoesController = TextEditingController();

  DateTime? _dataInicio;
  DateTime? _dataFim;

  // Função local para formatar data
  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChacaraController>().carregarInformacoes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Agendamento'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Consumer2<AgendamentoController, ChacaraController>(
        builder: (context, agendamentoController, chacaraController, child) {
          if (chacaraController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dados do Cliente',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nomeController,
                          decoration: const InputDecoration(
                            labelText: 'Nome completo *',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _telefoneController,
                          decoration: const InputDecoration(
                            labelText: 'Telefone *',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
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
                          'Dados do Agendamento',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _selecionarData(context, true),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Data início'),
                                          Text(
                                            _dataInicio != null
                                                ? _formatarData(_dataInicio!)
                                                : 'Selecionar',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: _dataInicio != null
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selecionarData(context, false),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Data fim'),
                                          Text(
                                            _dataFim != null
                                                ? _formatarData(_dataFim!)
                                                : 'Selecionar',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: _dataFim != null
                                                  ? Colors.black
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _pessoasController,
                          decoration: const InputDecoration(
                            labelText: 'Quantidade de pessoas *',
                            prefixIcon: Icon(Icons.people),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            }
                            final int? pessoas = int.tryParse(value);
                            if (pessoas == null || pessoas <= 0) {
                              return 'Valor inválido';
                            }
                            if (!chacaraController
                                .verificarCapacidade(pessoas)) {
                              return 'Máximo ${chacaraController.capacidadeMaxima} pessoas';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _observacoesController,
                          decoration: const InputDecoration(
                            labelText: 'Observações',
                            prefixIcon: Icon(Icons.notes),
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        if (_dataInicio != null && _dataFim != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info, color: Colors.green[700]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Valor total: R\$ ${agendamentoController.calcularValorTotal(_dataInicio!, _dataFim!, chacaraController.valorDiaria).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: agendamentoController.isLoading
                      ? null
                      : () => _salvarAgendamento(
                          agendamentoController, chacaraController),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: agendamentoController.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Salvar Agendamento'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selecionarData(BuildContext context, bool isInicio) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isInicio) {
          _dataInicio = picked;
          if (_dataFim != null && _dataFim!.isBefore(picked)) {
            _dataFim = null;
          }
        } else {
          if (_dataInicio == null ||
              picked.isAfter(_dataInicio!) ||
              picked.isAtSameMomentAs(_dataInicio!)) {
            _dataFim = picked;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data fim deve ser posterior à data início'),
              ),
            );
          }
        }
      });
    }
  }

  Future<void> _salvarAgendamento(
    AgendamentoController agendamentoController,
    ChacaraController chacaraController,
  ) async {
    if (_formKey.currentState!.validate()) {
      if (_dataInicio == null || _dataFim == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione as datas de início e fim')),
        );
        return;
      }

      final agendamento = AgendamentoDTO(
        nomeCliente: _nomeController.text,
        telefone: _telefoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        dataInicio: _dataInicio!,
        dataFim: _dataFim!,
        quantidadePessoas: int.parse(_pessoasController.text),
        valorTotal: agendamentoController.calcularValorTotal(
          _dataInicio!,
          _dataFim!,
          chacaraController.valorDiaria,
        ),
        status: 'Pendente',
        observacoes: _observacoesController.text.isEmpty
            ? null
            : _observacoesController.text,
      );

      final sucesso = await agendamentoController.criarAgendamento(agendamento);

      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agendamento salvo com sucesso!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(agendamentoController.erro ?? 'Erro desconhecido')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _pessoasController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }
}
