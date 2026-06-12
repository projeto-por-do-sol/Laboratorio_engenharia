import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quiosque.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pedidos (
        idPedido TEXT NOT NULL,
        idProduto TEXT NOT NULL,
        idCliente TEXT NOT NULL,
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
        PRIMARY KEY (idPedido)
      )
    ''');

    await db.execute('''
      CREATE TABLE quiosques (
        id TEXT PRIMARY KEY,
        nomeQuiosque TEXT NOT NULL,
        email TEXT NOT NULL,
        telefone TEXT NOT NULL,
        fotoPath TEXT
      )
    ''');

    await _createPedidosRecebidos(db);
  }

  Future _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createPedidosRecebidos(db);
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE pedidos_new (
          idPedido TEXT NOT NULL,
          idProduto TEXT NOT NULL,
          idCliente TEXT NOT NULL,
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
          PRIMARY KEY (idPedido)
        )
      ''');
      await db.execute('''
        INSERT INTO pedidos_new
        SELECT idPedido, idProduto, idQuiosque, codigoPedido, nomeQuiosque,
               imgBannerQuiosque, nomeItem, valorTotal, ingredientes, adicionais,
               qtdeItem, status, horaPedido
        FROM pedidos
      ''');
      await db.execute('DROP TABLE pedidos');
      await db.execute('ALTER TABLE pedidos_new RENAME TO pedidos');
    }
    if (oldVersion < 4) {
      await db.execute(
          'ALTER TABLE pedidos_recebidos ADD COLUMN clienteLat REAL');
      await db.execute(
          'ALTER TABLE pedidos_recebidos ADD COLUMN clienteLng REAL');
    }
  }

  Future _createPedidosRecebidos(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pedidos_recebidos (
        id TEXT PRIMARY KEY,
        nomeCliente TEXT NOT NULL,
        hora TEXT NOT NULL,
        status TEXT NOT NULL,
        codigo TEXT NOT NULL,
        itens TEXT NOT NULL,
        clienteLat REAL,
        clienteLng REAL
      )
    ''');
  }
}
