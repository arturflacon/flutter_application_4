import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/custom_app_bar.dart';
import '../models/servico.dart';
import '../database/database_helper.dart';

class ServicoFormScreen extends StatefulWidget {
  final Servico? servico;

  const ServicoFormScreen({Key? key, this.servico}) : super(key: key);

  @override
  State<ServicoFormScreen> createState() => _ServicoFormScreenState();
}

class _ServicoFormScreenState extends State<ServicoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();

  bool _ativo = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.servico != null) {
      _nomeController.text = widget.servico!.nome;
      _descricaoController.text = widget.servico!.descricao;
      _precoController.text = widget.servico!.preco.toStringAsFixed(2);
      _ativo = widget.servico!.ativo;
    }
  }

  Future<void> _salvarServico() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final preco =
          double.tryParse(_precoController.text.replaceAll(',', '.')) ?? 0.0;

      final servico = Servico(
        id: widget.servico?.id,
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        preco: preco,
        ativo: _ativo,
        dataCriacao: widget.servico?.dataCriacao ?? DateTime.now(),
      );

      if (widget.servico == null) {
        await DatabaseHelper.instance.insertServico(servico);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Serviço cadastrado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        await DatabaseHelper.instance.updateServico(servico);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Serviço atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar serviço: $e'),
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
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.servico == null ? 'Novo Serviço' : 'Editar Serviço',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Informações do Serviço',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomeController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nome do serviço',
                        prefixIcon: Icon(Icons.room_service),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nome é obrigatório';
                        }
                        if (value.trim().length < 3) {
                          return 'Nome deve ter pelo menos 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descricaoController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Descrição é obrigatória';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _precoController,
                      decoration: const InputDecoration(
                        labelText: 'Preço',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                        hintText: '0,00',
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Preço é obrigatório';
                        }
                        final preco =
                            double.tryParse(value.replaceAll(',', '.'));
                        if (preco == null || preco <= 0) {
                          return 'Preço deve ser maior que zero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Serviço ativo'),
                      subtitle: Text(_ativo
                          ? 'Este serviço estará disponível para agendamento'
                          : 'Este serviço não estará disponível para agendamento'),
                      value: _ativo,
                      onChanged: (value) {
                        setState(() => _ativo = value);
                      },
                      activeColor: const Color(0xFF2E7D32),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _salvarServico,
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
                  : Text(
                      widget.servico == null
                          ? 'Cadastrar Serviço'
                          : 'Atualizar Serviço',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }
}
