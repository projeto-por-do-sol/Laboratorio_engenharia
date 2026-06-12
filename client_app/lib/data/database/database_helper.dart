import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cliente.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pedidos (
        idPedido TEXT NOT NULL,
        idProduto TEXT NOT NULL,
        idQuiosque TEXT NOT NULL,
        codigoPedido TEXT NOT NULL,
        nomeQuiosque TEXT NOT NULL,
        imgBannerQuiosque TEXT,
        nomeItem TEXT NOT NULL,
        valorTotal INTEGER NOT NULL,
        ingredientes TEXT,
        adicionais TEXT,
        qtdeItem INTEGER NOT NULL,
        status TEXT NOT NULL,
        horaPedido TEXT NOT NULL,
        PRIMARY KEY (idPedido, idProduto, idQuiosque)
      )
    ''');

    await db.execute('''
      CREATE TABLE clientes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nomeCompleto TEXT NOT NULL,
        email TEXT NOT NULL,
        telefone TEXT NOT NULL,
        fotoPath TEXT
      )
    ''');
  }

  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS clientes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nomeCompleto TEXT NOT NULL,
          email TEXT NOT NULL,
          telefone TEXT NOT NULL,
          fotoPath TEXT
        )
      ''');
    }
  }
}
