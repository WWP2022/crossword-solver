import 'dart:async';

import 'package:crossword_solver/model/crossword_info.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class CrosswordDatabase {
  static final CrosswordDatabase instance = CrosswordDatabase._init();
  static Database? _database;

  CrosswordDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('crosswordDatabase.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    print("creating database");
    await db.execute('CREATE TABLE $crosswordInfoTable('
        '${CrosswordInfoFields.id} INTEGER PRIMARY KEY,'
        '${CrosswordInfoFields.path}  TEXT,'
        '${CrosswordInfoFields.crosswordName}  TEXT,'
        '${CrosswordInfoFields.timestamp}  TEXT,'
        '${CrosswordInfoFields.userId}  TEXT,'
        '${CrosswordInfoFields.status}  TEXT)');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
