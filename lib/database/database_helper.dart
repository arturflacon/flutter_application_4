import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/cliente.dart';
import '../models/servico.dart';
import '../models/agendamento.dart';
import '../models/agendamento_servico.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (kIsWeb) {
      throw UnsupportedError('SQLite não é suportado nativamente no navegador. '
          'Execute a aplicação em um dispositivo móvel ou desktop.');
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // ⭐ CORREÇÃO: Garantir que o WidgetsFlutterBinding seja inicializado
    WidgetsFlutterBinding.ensureInitialized();

    try {
      String path = join(await getDatabasesPath(), 'chacara_booking.db');
      return await openDatabase(
        path,
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      print('❌ Erro ao inicializar banco de dados: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      // Tabela de clientes
      await db.execute('''
        CREATE TABLE clientes(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          telefone TEXT NOT NULL,
          email TEXT NOT NULL,
          cpf TEXT NOT NULL UNIQUE,
          dataCadastro INTEGER NOT NULL
        )
      ''');

      // ✅ Tabela de serviços com data_criacao
      await db.execute('''
        CREATE TABLE servicos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL,
          descricao TEXT NOT NULL,
          preco REAL NOT NULL,
          ativo INTEGER NOT NULL DEFAULT 1,
          data_criacao INTEGER NOT NULL
        )
      ''');

      // Tabela de agendamentos
      await db.execute('''
        CREATE TABLE agendamentos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          clienteId INTEGER NOT NULL,
          dataReserva INTEGER NOT NULL,
          dataEvento INTEGER NOT NULL,
          periodo TEXT NOT NULL,
          valorTotal REAL NOT NULL,
          status TEXT NOT NULL DEFAULT 'pendente',
          observacoes TEXT,
          FOREIGN KEY (clienteId) REFERENCES clientes (id)
        )
      ''');

      // Tabela associativa N:N entre agendamentos e serviços
      await db.execute('''
        CREATE TABLE agendamento_servicos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          agendamentoId INTEGER NOT NULL,
          servicoId INTEGER NOT NULL,
          quantidade INTEGER NOT NULL DEFAULT 1,
          precoUnitario REAL NOT NULL,
          FOREIGN KEY (agendamentoId) REFERENCES agendamentos (id),
          FOREIGN KEY (servicoId) REFERENCES servicos (id)
        )
      ''');

      // Inserir dados iniciais
      await _insertInitialData(db);
      print('✅ Banco de dados criado com sucesso');
    } catch (e) {
      print('❌ Erro ao criar tabelas: $e');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        // Verificar se a coluna já existe antes de tentar adicioná-la
        final result = await db.rawQuery("PRAGMA table_info(servicos)");
        bool hasDataCriacao =
            result.any((column) => column['name'] == 'data_criacao');

        if (!hasDataCriacao) {
          await db.execute('''
            ALTER TABLE servicos ADD COLUMN data_criacao INTEGER DEFAULT ${DateTime.now().millisecondsSinceEpoch}
          ''');

          await db.execute('''
            UPDATE servicos SET data_criacao = ${DateTime.now().millisecondsSinceEpoch} WHERE data_criacao IS NULL
          ''');

          print('✅ Migração concluída: Coluna data_criacao adicionada');
        }
      } catch (e) {
        print('⚠️ Erro na migração: $e');
        rethrow;
      }
    }
  }

  Future<void> _insertInitialData(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      // Verificar se já existem dados antes de inserir
      final existingServices = await db.query('servicos');
      if (existingServices.isEmpty) {
        await db.insert('servicos', {
          'nome': 'Churrasqueira',
          'descricao': 'Uso da churrasqueira com utensílios',
          'preco': 50.0,
          'ativo': 1,
          'data_criacao': now,
        });

        await db.insert('servicos', {
          'nome': 'Piscina',
          'descricao': 'Acesso à piscina com limpeza',
          'preco': 80.0,
          'ativo': 1,
          'data_criacao': now,
        });

        await db.insert('servicos', {
          'nome': 'Som ambiente',
          'descricao': 'Sistema de som para festa',
          'preco': 30.0,
          'ativo': 1,
          'data_criacao': now,
        });

        await db.insert('servicos', {
          'nome': 'Decoração básica',
          'descricao': 'Decoração simples com flores',
          'preco': 100.0,
          'ativo': 1,
          'data_criacao': now,
        });

        print('✅ Dados iniciais inseridos com sucesso');
      }
    } catch (e) {
      print('⚠️ Erro ao inserir dados iniciais: $e');
    }
  }

  // ✅ Métodos com verificação de plataforma
  Future<T> _executeWithPlatformCheck<T>(Future<T> Function() operation) async {
    if (kIsWeb) {
      throw UnsupportedError(
          'Esta operação não é suportada no navegador. Use um dispositivo móvel ou desktop.');
    }
    return await operation();
  }

  // CRUD Clientes com verificação de plataforma
  Future<int> insertCliente(Cliente cliente) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      return await db.insert('clientes', cliente.toMap());
    });
  }

  Future<List<Cliente>> getClientes() async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      final List<Map<String, dynamic>> maps =
          await db.query('clientes', orderBy: 'nome ASC');
      return List.generate(maps.length, (i) => Cliente.fromMap(maps[i]));
    });
  }

  Future<Cliente?> getCliente(int id) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'clientes',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Cliente.fromMap(maps.first);
      }
      return null;
    });
  }

  Future<int> updateCliente(Cliente cliente) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      return await db.update(
        'clientes',
        cliente.toMap(),
        where: 'id = ?',
        whereArgs: [cliente.id],
      );
    });
  }

  Future<int> deleteCliente(int id) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      return await db.delete(
        'clientes',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // CRUD Serviços com verificação de plataforma
  Future<int> insertServico(Servico servico) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      return await db.insert('servicos', servico.toMap());
    });
  }

  Future<List<Servico>> getServicos() async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      final List<Map<String, dynamic>> maps =
          await db.query('servicos', orderBy: 'nome ASC');
      return List.generate(maps.length, (i) => Servico.fromMap(maps[i]));
    });
  }

  Future<List<Servico>> getServicosAtivos() async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'servicos',
        where: 'ativo = ?',
        whereArgs: [1],
        orderBy: 'nome ASC',
      );
      return List.generate(maps.length, (i) => Servico.fromMap(maps[i]));
    });
  }

  Future<Servico?> getServico(int id) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'servicos',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Servico.fromMap(maps.first);
      }
      return null;
    });
  }

  Future<int> updateServico(Servico servico) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      return await db.update(
        'servicos',
        servico.toMap(),
        where: 'id = ?',
        whereArgs: [servico.id],
      );
    });
  }

  Future<int> deleteServico(int id) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      return await db.delete(
        'servicos',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // CRUD Agendamentos com verificação de plataforma
  Future<int> insertAgendamento(Agendamento agendamento) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      return await db.insert('agendamentos', agendamento.toMap());
    });
  }

  Future<List<Agendamento>> getAgendamentos() async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT a.*, c.nome as cliente_nome, c.telefone as cliente_telefone, 
               c.email as cliente_email, c.cpf as cliente_cpf, c.dataCadastro as cliente_dataCadastro
        FROM agendamentos a
        INNER JOIN clientes c ON a.clienteId = c.id
        ORDER BY a.dataEvento DESC
      ''');

      List<Agendamento> agendamentos = [];
      for (var map in maps) {
        Agendamento agendamento = Agendamento.fromMap(map);
        agendamento.cliente = Cliente(
          id: agendamento.clienteId,
          nome: map['cliente_nome'],
          telefone: map['cliente_telefone'],
          email: map['cliente_email'] ?? '',
          cpf: map['cliente_cpf'] ?? '',
          dataCadastro: DateTime.fromMillisecondsSinceEpoch(
              map['cliente_dataCadastro'] ??
                  DateTime.now().millisecondsSinceEpoch),
        );

        agendamento.servicos = await getServicosDoAgendamento(agendamento.id!);
        agendamentos.add(agendamento);
      }
      return agendamentos;
    });
  }

  Future<Agendamento?> getAgendamento(int id) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT a.*, c.nome as cliente_nome, c.telefone as cliente_telefone, 
               c.email as cliente_email, c.cpf as cliente_cpf, c.dataCadastro as cliente_dataCadastro
        FROM agendamentos a
        INNER JOIN clientes c ON a.clienteId = c.id
        WHERE a.id = ?
      ''', [id]);

      if (maps.isNotEmpty) {
        var map = maps.first;
        Agendamento agendamento = Agendamento.fromMap(map);
        agendamento.cliente = Cliente(
          id: agendamento.clienteId,
          nome: map['cliente_nome'],
          telefone: map['cliente_telefone'],
          email: map['cliente_email'] ?? '',
          cpf: map['cliente_cpf'] ?? '',
          dataCadastro: DateTime.fromMillisecondsSinceEpoch(
              map['cliente_dataCadastro'] ??
                  DateTime.now().millisecondsSinceEpoch),
        );
        agendamento.servicos = await getServicosDoAgendamento(agendamento.id!);
        return agendamento;
      }
      return null;
    });
  }

  Future<int> updateAgendamento(Agendamento agendamento) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      return await db.update(
        'agendamentos',
        agendamento.toMap(),
        where: 'id = ?',
        whereArgs: [agendamento.id],
      );
    });
  }

  Future<int> deleteAgendamento(int id) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      await deleteAgendamentoServicos(id);
      return await db.delete(
        'agendamentos',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<List<Servico>> getServicosDoAgendamento(int agendamentoId) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT s.*, ag.quantidade, ag.precoUnitario FROM servicos s
        INNER JOIN agendamento_servicos ag ON s.id = ag.servicoId
        WHERE ag.agendamentoId = ?
      ''', [agendamentoId]);

      return List.generate(maps.length, (i) => Servico.fromMap(maps[i]));
    });
  }

  Future<bool> isDataDisponivel(DateTime data, String periodo) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      final startOfDay = DateTime(data.year, data.month, data.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final List<Map<String, dynamic>> maps = await db.query(
        'agendamentos',
        where:
            'dataEvento >= ? AND dataEvento < ? AND (periodo = ? OR periodo = ?) AND status != ?',
        whereArgs: [
          startOfDay.millisecondsSinceEpoch,
          endOfDay.millisecondsSinceEpoch,
          periodo,
          'dia_todo',
          'cancelado'
        ],
      );

      return maps.isEmpty;
    });
  }

  // CRUD Agendamento_Servicos
  Future<int> insertAgendamentoServico(
      AgendamentoServico agendamentoServico) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      return await db.insert(
          'agendamento_servicos', agendamentoServico.toMap());
    });
  }

  Future<void> deleteAgendamentoServicos(int agendamentoId) async {
    await _executeWithPlatformCheck(() async {
      final db = await database;
      await db.delete(
        'agendamento_servicos',
        where: 'agendamentoId = ?',
        whereArgs: [agendamentoId],
      );
    });
  }

  Future<List<AgendamentoServico>> getAgendamentoServicos(
      int agendamentoId) async {
    return await _executeWithPlatformCheck(() async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'agendamento_servicos',
        where: 'agendamentoId = ?',
        whereArgs: [agendamentoId],
      );
      return List.generate(
          maps.length, (i) => AgendamentoServico.fromMap(maps[i]));
    });
  }

  // Método para verificar integridade do banco
  Future<void> verificarIntegridade() async {
    await _executeWithPlatformCheck(() async {
      final db = await database;
      final result = await db.rawQuery("PRAGMA integrity_check");
      print('✅ Verificação de integridade: ${result.first['integrity_check']}');
    });
  }

  // Método para fechar o banco corretamente
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
