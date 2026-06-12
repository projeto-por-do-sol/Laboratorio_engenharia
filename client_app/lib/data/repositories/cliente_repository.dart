import 'package:client_app/data/database/database_helper.dart';
import 'package:client_app/src/shared/models/cliente_model.dart';
import 'package:sqflite/sqflite.dart';

class ClienteRepository {
  static final ClienteRepository instance = ClienteRepository._init();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  ClienteRepository._init();

  Future<ClienteModel?> buscarCliente() async {
    final db = await _dbHelper.database;
    final results = await db.query('clientes', limit: 1);
    if (results.isEmpty) return null;
    return ClienteModel.fromMap(results.first);
  }

  Future<int> inserirCliente(ClienteModel cliente) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'clientes',
      cliente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> atualizarCliente(ClienteModel cliente) async {
    final db = await _dbHelper.database;
    return await db.update(
      'clientes',
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
  }

  Future<int> deletarCliente() async {
    final db = await _dbHelper.database;
    return await db.delete('clientes');
  }
}
