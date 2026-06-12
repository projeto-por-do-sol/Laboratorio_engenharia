import 'package:quiosque_app/data/database/database_helper.dart';
import 'package:quiosque_app/src/shared/models/pedido_recebido.dart';
import 'package:sqflite/sqflite.dart';

class PedidoRecebidoRepository {
  static final PedidoRecebidoRepository instance =
      PedidoRecebidoRepository._init();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  PedidoRecebidoRepository._init();

  Future<List<PedidoRecebido>> listar() async {
    final db = await _dbHelper.database;
    final results = await db.query('pedidos_recebidos', orderBy: 'hora ASC');
    return results.map((m) => PedidoRecebido.fromMap(m)).toList();
  }

  Future<void> inserir(PedidoRecebido pedido) async {
    final db = await _dbHelper.database;
    await db.insert(
      'pedidos_recebidos',
      pedido.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> atualizarStatus(String id, String status) async {
    final db = await _dbHelper.database;
    await db.update(
      'pedidos_recebidos',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deletar(String id) async {
    final db = await _dbHelper.database;
    await db.delete('pedidos_recebidos', where: 'id = ?', whereArgs: [id]);
  }
}
