const String photoTable = 'photos';

class PhotoFields {
  static final List<String> values = [id, path, name, date];

  static const String id = '_id';
  static const String path = '_path';
  static const String name = '_name';
  static const String date = 'date';
}

class Photo {
  final int? id;
  final String path;
  final String name;
  final DateTime date;

  const Photo({
    this.id,
    required this.path,
    required this.name,
    required this.date,
  });

  Map<String, Object?> toJson() => {
        PhotoFields.id: id,
        PhotoFields.path: path,
        PhotoFields.name: name,
        PhotoFields.date: date.toIso8601String(),
      };

  Photo copy({int? id, String? path, String? name, DateTime? date}) => Photo(
        id: id ?? this.id,
        path: path ?? this.path,
        name: name ?? this.name,
        date: date ?? this.date,
      );

  @override
  String toString() {
    return 'Photo{id: $id, path: $path, name: $name, date: $date}';
  }

  static Photo fromJson(Map<String, Object?> json) => Photo(
      id: json[PhotoFields.id] as int?,
      path: json[PhotoFields.path] as String,
      name: json[PhotoFields.name] as String,
      date: DateTime.parse(json[PhotoFields.date] as String)
  );

}
