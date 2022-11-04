import 'package:sqflite/sqflite.dart';

import '../model/photo.dart';
import 'crosswordDatabase.dart';

class PhotoRepository {
  Future<Photo> insertPhoto(Photo photo) async {
    final db = await CrosswordDatabase.instance.database;
    final id = await db.insert(
      'photos',
      photo.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return photo.copy(id: id);
  }

  Future<Photo> getPhoto(int id) async {
    final db = await CrosswordDatabase.instance.database;
    final maps = await db.query('photos',
        columns: PhotoFields.values,
        where: '${PhotoFields.id} = ?',
        whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Photo.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Photo>> getAllPhotos() async {
    final db = await CrosswordDatabase.instance.database;

    final result = await db.query('photos');

    return result.map((json) => Photo.fromJson(json)).toList();
  }

  Future<int> deletePhoto(int id) async {
    final db = await CrosswordDatabase.instance.database;

    return await db
        .delete('photos', where: '${PhotoFields.id} = ?', whereArgs: [id]);
  }
}
