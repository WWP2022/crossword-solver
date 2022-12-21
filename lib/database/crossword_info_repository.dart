import 'package:sqflite/sqflite.dart';

import '../model/crossword_info.dart';
import 'crossword_database.dart';

//TODO After we add photo processing, we will have many crossword with suffixes
//TODO such as _processed, _raw, We will need to change logic for it later.
class CrosswordInfoRepository {
  static const String tableName = "crossword_info";

  Future<CrosswordInfo> insertCrosswordInfo(CrosswordInfo crosswordInfo) async {
    final db = await CrosswordDatabase.instance.database;
    final id = await db.insert(
      tableName,
      crosswordInfo.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return crosswordInfo.copy(id: id);
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

  Future<int> updateCrosswordInfo(CrosswordInfo crosswordInfo) async {
    final db = await CrosswordDatabase.instance.database;
    return db.update(tableName, crosswordInfo.toJson(),
        where: '${CrosswordInfoFields.id} = ?', whereArgs: [crosswordInfo.id]);
  }

  Future<List<CrosswordInfo>> getAllCrosswordsInfo(String userId) async {
    final db = await CrosswordDatabase.instance.database;

    final result = await db.query(tableName,
        where:
            '${CrosswordInfoFields.userId} = ? and (${CrosswordInfoFields.status} = ? or ${CrosswordInfoFields.status} = ?)',
        whereArgs: [userId, "solved_waiting", "solved_accepted"]);

    return result.map((json) => CrosswordInfo.fromJson(json)).toList();
  }

  Future<int> deleteCrosswordInfo(int id) async {
    final db = await CrosswordDatabase.instance.database;

    return await db.delete(tableName,
        where: '${CrosswordInfoFields.id} = ?', whereArgs: [id]);
  }
}
