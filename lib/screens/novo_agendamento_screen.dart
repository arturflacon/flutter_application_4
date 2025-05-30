import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_card.dart';
import '../models/cliente.dart';
import '../models/servico.dart';
import '../models/agendamento.dart';
import '../models/agendamento_servico.dart';
import '../database/database_helper.dart';

class NovoAgendamentoScreen extends StatefulWidget {
  const NovoAgendamentoScreen({Key? key}) : super(key: key);

  @override
  State<NovoAgendamentoScreen> createState() => _NovoAgendamentoScreenState();
}

class _NovoAgendamentoScreenState extends State<NovoAgendamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _observacoesController = TextEditingController();

  Cliente? _clienteSelecionado;
  DateTime? _dataEvento;
  String _periodoSelecionado = 'dia_todo';
  List<Cliente> _clientes = [];
  List<Servico> _servicosDisponiveis = [];
  List<Servico> _servicosSelecionados = [];
  bool _isLoading = false;
  bool _isLoadingData = true;

  final List<Map<String, String>> _periodos = [
    {'value': 'manha', 'label': 'Manhã (06:00 - 12:00)'},
    {'value': 'tarde', 'label': 'Tarde (12:00 - 18:00)'},
    {'value': 'noite', 'label': 'Noite (18:00 - 00:00)'},
    {'value': 'dia_todo', 'label': 'Dia Todo (06:00 - 00:00)'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final clientes = await DatabaseHelper.instance.getClientes();
      final servicos = await DatabaseHelper.instance.getServicosAtivos();

      if (mounted) {
        setState(() {
          _clientes = clientes;
          _servicosDisponiveis = servicos;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF2E7D32),
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      // Verificar disponibilidade
      try {
        final disponivel = await DatabaseHelper.instance
            .isDataDisponivel(picked, _periodoSelecionado);

        if (disponivel) {
          setState(() {
            _dataEvento = picked;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Data/período não disponível. Escolha outra opção.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao verificar disponibilidade: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _toggleServico(Servico servico) {
    setState(() {
      if (_servicosSelecionados.contains(servico)) {
        _servicosSelecionados.remove(servico);
      } else {
        _servicosSelecionados.add(servico);
      }
    });
  }

  double _calcularValorTotal() {
    return _servicosSelecionados.fold(
        0.0, (total, servico) => total + servico.preco);
  }

  Future<void> _salvarAgendamento() async {
    if (!_formKey.currentState!.validate()) return;

    if (_clienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente')),
      );
      return;
    }

    if (_dataEvento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data do evento')),
      );
      return;
    }

    if (_servicosSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um serviço')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Verificar disponibilidade novamente
      final disponivel = await DatabaseHelper.instance
          .isDataDisponivel(_dataEvento!, _periodoSelecionado);

      if (!disponivel) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data/período não está mais disponível'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final agendamento = Agendamento(
        clienteId: _clienteSelecionado!.id!,
        dataReserva: DateTime.now(),
        dataEvento: _dataEvento!,
        periodo: _periodoSelecionado,
        valorTotal: _calcularValorTotal(),
        observacoes: _observacoesController.text.trim().isEmpty
            ? null
            : _observacoesController.text.trim(),
      );

      final agendamentoId =
          await DatabaseHelper.instance.insertAgendamento(agendamento);

      // Inserir serviços associados
      for (final servico in _servicosSelecionados) {
        final agendamentoServico = AgendamentoServico(
          agendamentoId: agendamentoId,
          servicoId: servico.id!,
          quantidade: 1,
          precoUnitario: servico.preco,
        );
        await DatabaseHelper.instance
            .insertAgendamentoServico(agendamentoServico);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar agendamento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        appBar: CustomAppBar(title: 'Novo Agendamento'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando dados...'),
            ],
          ),
        ),
      );
    }

    if (_clientes.isEmpty) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Novo Agendamento'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.people_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhum cliente cadastrado',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cadastre um cliente primeiro para criar agendamentos',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Novo Agendamento'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Seleção de Cliente
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cliente',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Cliente>(
                    value: _clienteSelecionado,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Selecione um cliente',
                      prefixIcon: Icon(Icons.person),
                    ),
                    isExpanded: true,
                    items: _clientes.map((cliente) {
                      return DropdownMenuItem<Cliente>(
                        value: cliente,
                        child: Text(
                          '${cliente.nome} - ${cliente.telefone}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (cliente) {
                      setState(() {
                        _clienteSelecionado = cliente;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Selecione um cliente';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Data e Período
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data e Período',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _selecionarData,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            _dataEvento == null
                                ? 'Selecionar data do evento'
                                : DateFormat('dd/MM/yyyy', 'pt_BR')
                                    .format(_dataEvento!),
                            style: TextStyle(
                              fontSize: 16,
                              color: _dataEvento == null
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _periodoSelecionado,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Período',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    items: _periodos.map((periodo) {
                      return DropdownMenuItem<String>(
                        value: periodo['value'],
                        child: Text(periodo['label']!),
                      );
                    }).toList(),
                    onChanged: (periodo) {
                      if (periodo != null) {
                        setState(() {
                          _periodoSelecionado = periodo;
                          _dataEvento = null; // Reset data when changing period
                        });
                      }
                    },
                  ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Serviços',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      if (_servicosSelecionados.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Total: R\$ ${_calcularValorTotal().toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_servicosDisponiveis.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Nenhum serviço disponível',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    Column(
                      children: _servicosDisponiveis.map((servico) {
                        final selecionado =
                            _servicosSelecionados.contains(servico);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: CheckboxListTile(
                            title: Text(
                              servico.nome,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (servico.descricao.isNotEmpty)
                                  Text(servico.descricao),
                                const SizedBox(height: 4),
                                Text(
                                  'R\$ ${servico.preco.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                            value: selecionado,
                            onChanged: (bool? value) {
                              _toggleServico(servico);
                            },
                            activeColor: const Color(0xFF2E7D32),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Observações
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Observações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _observacoesController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Observações adicionais (opcional)',
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                    maxLength: 500,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botão Salvar
            ElevatedButton(
              onPressed: _isLoading ? null : _salvarAgendamento,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Criar Agendamento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
