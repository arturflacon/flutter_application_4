import 'package:flutter/material.dart';
import '../components/custom_app_bar.dart';
import '../components/custom_card.dart';
import '../models/servico.dart';
import '../database/database_helper.dart';
import 'servico_form_screen.dart';

class ServicosScreen extends StatefulWidget {
  const ServicosScreen({Key? key}) : super(key: key);

  @override
  State<ServicosScreen> createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  List<Servico> servicos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServicos();
  }

  Future<void> _loadServicos() async {
    try {
      final servicosList = await DatabaseHelper.instance.getServicos();
      if (mounted) {
        setState(() {
          servicos = servicosList;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar serviços: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleServicoStatus(Servico servico) async {
    try {
      final updatedServico = Servico(
        id: servico.id,
        nome: servico.nome,
        descricao: servico.descricao,
        preco: servico.preco,
        ativo: !servico.ativo,
        dataCriacao: servico.dataCriacao,
      );

      await DatabaseHelper.instance.updateServico(updatedServico);
      _loadServicos();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Serviço ${updatedServico.ativo ? 'ativado' : 'desativado'} com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar serviço: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Serviços'),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ServicoFormScreen(),
            ),
          );
          if (result == true) {
            _loadServicos();
          }
        },
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : servicos.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.room_service_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum serviço cadastrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: servicos.length,
                  itemBuilder: (context, index) {
                    final servico = servicos[index];
                    return CustomCard(
                      color: servico.ativo ? null : Colors.grey.shade100,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: servico.ativo
                              ? const Color(0xFF2E7D32)
                              : Colors.grey,
                          child: const Icon(
                            Icons.room_service,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          servico.nome,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: servico.ativo ? Colors.black : Colors.grey,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              servico.descricao,
                              style: TextStyle(
                                color: servico.ativo
                                    ? Colors.black87
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'R\$ ${servico.preco.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    servico.ativo ? Colors.green : Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            switch (value) {
                              case 'toggle':
                                await _toggleServicoStatus(servico);
                                break;
                              case 'edit':
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ServicoFormScreen(
                                      servico: servico,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadServicos();
                                }
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'toggle',
                              child: Row(
                                children: [
                                  Icon(servico.ativo
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  const SizedBox(width: 8),
                                  Text(servico.ativo ? 'Desativar' : 'Ativar'),
                                ],
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
