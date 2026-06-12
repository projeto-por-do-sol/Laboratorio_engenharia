import 'package:quiosque_app/data/database/database_helper.dart';
import 'package:quiosque_app/src/shared/models/quiosque_model.dart';
import 'package:sqflite/sqflite.dart';

class QuiosqueRepository {
  static final QuiosqueRepository instance = QuiosqueRepository._init();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  QuiosqueRepository._init();

  Future<QuiosqueModel?> buscarQuiosque() async {
    final db = await _dbHelper.database;
    final results = await db.query('quiosques', limit: 1);
    if (results.isEmpty) return null;
    return QuiosqueModel.fromMap(results.first);
  }

  Future<int> inserirQuiosque(QuiosqueModel quiosque) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'quiosques',
      quiosque.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> atualizarQuiosque(QuiosqueModel quiosque) async {
    final db = await _dbHelper.database;
    return await db.update(
      'quiosques',
      quiosque.toMap(),
      where: 'id = ?',
      whereArgs: [quiosque.id],
    );
  }

  Future<int> deletarQuiosque() async {
    final db = await _dbHelper.database;
    return await db.delete('quiosques');
  }
}
