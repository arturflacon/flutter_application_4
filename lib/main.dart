// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/agendamentocontroller.dart';
import 'controllers/chacaracontroller.dart';
import 'view/homeview.dart';
import 'view/agendamentoview.dart';
import 'view/novoagendamentoview.dart';
import 'view/detalhesagendamentoview.dart';

void main() {
  runApp(const ChacaraApp());
}

class ChacaraApp extends StatelessWidget {
  const ChacaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AgendamentoController()),
        ChangeNotifierProvider(create: (_) => ChacaraController()),
      ],
      child: MaterialApp(
        title: 'Agendamento Chácara',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomeView(),
        routes: {
          '/home': (context) => const HomeView(),
          '/agendamentos': (context) => const AgendamentosView(),
          '/novo-agendamento': (context) => const NovoAgendamentoView(),
          '/detalhes-agendamento': (context) => const DetalhesAgendamentoView(),
        },
      ),
    );
  }
}
