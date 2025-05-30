import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';
import 'database/database_helper.dart';

void main() async {
  // ⭐ CORREÇÃO CRÍTICA: Inicializar bindings antes de qualquer operação assíncrona
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar formatação de data para português brasileiro
    await initializeDateFormatting('pt_BR', null);

    // ⭐ CORREÇÃO: Verificar se estamos em ambiente web
    if (!kIsWeb) {
      // Inicializar banco de dados apenas em mobile/desktop
      print('🔄 Inicializando banco de dados...');
      await DatabaseHelper.instance.database;
      await DatabaseHelper.instance.verificarIntegridade();
      print('✅ Banco de dados inicializado com sucesso!');
    } else {
      print('🌐 Executando em ambiente web - usando armazenamento local');
    }
  } catch (e) {
    print('❌ Erro na inicialização: $e');
    // Mesmo com erro, vamos continuar para mostrar uma tela de erro amigável
  }

  runApp(const ChacaraBookingApp());
}

class ChacaraBookingApp extends StatelessWidget {
  const ChacaraBookingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chácara Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      // ✅ Usar o wrapper seguro para tratamento de erro
      home: const SafeHomeScreen(),
    );
  }
}

// ✅ Wrapper para a HomeScreen com tratamento de erro
class SafeHomeScreen extends StatefulWidget {
  const SafeHomeScreen({Key? key}) : super(key: key);

  @override
  State<SafeHomeScreen> createState() => _SafeHomeScreenState();
}

class _SafeHomeScreenState extends State<SafeHomeScreen> {
  bool _hasError = false;
  String _errorMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkDatabaseConnection();
  }

  Future<void> _checkDatabaseConnection() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      if (kIsWeb) {
        // Em ambiente web, pular verificação do banco
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Tentar conectar ao banco apenas em mobile/desktop
      await DatabaseHelper.instance.database;
      await DatabaseHelper.instance.getServicos();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF2E7D32),
              ),
              SizedBox(height: 16),
              Text(
                'Inicializando aplicação...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erro na Inicialização'),
          backgroundColor: Colors.red,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Erro ao inicializar o banco de dados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (kIsWeb) ...[
                const Text(
                  'Nota: SQLite não é suportado nativamente no navegador.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Para testar a aplicação, use um dispositivo móvel ou execute no modo desktop.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _checkDatabaseConnection();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Tentar Novamente'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _isLoading = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
                child: const Text('Continuar Mesmo Assim'),
              ),
            ],
          ),
        ),
      );
    }

    return const HomeScreen();
  }
}
