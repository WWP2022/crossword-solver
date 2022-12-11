import 'package:sqflite/sqflite.dart';

import '../model/crossword_info.dart';
import 'crossword_database.dart';

//TODO After we add photo processing, we will have many crossword with suffixes
//TODO such as _processed, _raw, We will need to change logic for it later.
class CrosswordInfoRepository {
  static const String tableName = "crossword_info";

  Future<CrosswordInfo> insertCrosswordInfo(CrosswordInfo photo) async {
    final db = await CrosswordDatabase.instance.database;
    final id = await db.insert(
      tableName,
      photo.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return photo.copy(id: id);
  }

  Future<CrosswordInfo> getCrosswordInfo(int id) async {
    final db = await CrosswordDatabase.instance.database;
    final maps = await db.query(tableName,
        columns: CrosswordInfoFields.values,
        where: '${CrosswordInfoFields.id} = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return CrosswordInfo.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<int> updateCrosswordInfo(CrosswordInfo photo) async {
    final db = await CrosswordDatabase.instance.database;
    return db.update(tableName, photo.toJson(),
        where: '${CrosswordInfoFields.id} = ?', whereArgs: [photo.id]);
  }

  Future<List<CrosswordInfo>> getAllCrosswordsInfo() async {
    final db = await CrosswordDatabase.instance.database;

    final result = await db.query(tableName);

    return result.map((json) => CrosswordInfo.fromJson(json)).toList();
  }

  Future<int> deleteCrosswordInfo(int id) async {
    final db = await CrosswordDatabase.instance.database;

    return await db.delete(tableName,
        where: '${CrosswordInfoFields.id} = ?', whereArgs: [id]);
  }
}
