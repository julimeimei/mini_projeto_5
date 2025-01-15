import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

class DbUtil {
  static sql.Database? _database;

  static Future<sql.Database> openDatabaseConnection() async {
    if (_database != null) return _database!;
    final databasePath = await sql.getDatabasesPath();
    final pathToDatabase = path.join(databasePath, 'places.db');

    _database = await sql.openDatabase(
      pathToDatabase,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE places (
            id TEXT PRIMARY KEY,
            title TEXT,
            image TEXT,
            location_latitude REAL,
            location_longitude REAL,
            location_address TEXT,
            phone TEXT,
            email TEXT
          )
        ''');
      },
      version: 1,
    );
    return _database!;
  }


  static Future<void> insert(String table, Map<String, Object> data) async {
    //return Future.value();
    final db = await DbUtil.openDatabaseConnection();
    await db.insert(
      table,
      data,
      conflictAlgorithm: sql
          .ConflictAlgorithm.replace, //se inserir algo conlfitante (substitui)
    );
  }



  static Future<void> update(
  String table, 
  Map<String, Object> data, 
  String whereClause, 
  List<Object?> whereArgs
) async {
  final db = await DbUtil.openDatabaseConnection();
  await db.update(
    table,
    data,
    where: whereClause,
    whereArgs: whereArgs,
  );
}

  

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DbUtil.openDatabaseConnection();
    return db.query(table);
  }

  

  static Future<void> deletePlaceFromSQLite(String id) async {
    try {
      final db = await DbUtil.openDatabaseConnection();
      await db.delete(
        'places',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Erro ao excluir do SQLite: $e');
    }
  }
}
