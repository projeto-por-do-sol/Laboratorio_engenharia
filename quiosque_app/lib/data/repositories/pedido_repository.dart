
import 'package:quiosque_app/data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class PedidoRepository {
  static final PedidoRepository instance = PedidoRepository._init();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  PedidoRepository._init();

  Future<List<Map<String, dynamic>>> listarPedidos() async {
    final db = await _dbHelper.database;
    return await db.query('pedidos');
  }

  Future<int> inserirItem(Map<String, dynamic> dadosPedido) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'pedidos',
      dadosPedido,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> atualizarStatus(String idPedido, String novoStatus) async {
    final db = await _dbHelper.database;
    return await db.update(
      'pedidos',
      {'status': novoStatus},
      where: 'idPedido = ?',
      whereArgs: [idPedido],
    );
  }

  Future<int> deletarPedido() async {
    final db = await _dbHelper.database;
    return await db.delete(
      'pedidos',
    );
  }

  Future<int> deletarPedidoIdPedidoIdQuiosque(String idPedido) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'pedidos',
      where: 'idPedido = ?',
      whereArgs: [idPedido],
    );
  }

  Future<int> finalizarTodos() async {
    final db = await _dbHelper.database;
    return await db.update(
      'pedidos',
      {'status': 'Finalizado'},
      where: "status != ?",
      whereArgs: ['Finalizado'],
    );
  }
}