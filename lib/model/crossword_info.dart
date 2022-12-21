const String crosswordInfoTable = 'crossword_info';

class CrosswordInfoFields {
  static final List<String> values = [
    id,
    path,
    crosswordName,
    timestamp,
    userId,
    status
  ];

  static const String id = '_id';
  static const String path = '_path';
  static const String crosswordName = '_crosswordName';
  static const String timestamp = '_timestamp';
  static const String userId = '_user_id';
  static const String status = '_status';
}

class CrosswordInfo {
  final int id;
  final String path;
  String crosswordName;
  final DateTime timestamp;
  final String userId;
  final String status;

  CrosswordInfo({
    required this.id,
    required this.path,
    required this.crosswordName,
    required this.timestamp,
    required this.userId,
    required this.status,
  });

  Map<String, Object?> toJson() => {
        CrosswordInfoFields.id: id,
        CrosswordInfoFields.path: path,
        CrosswordInfoFields.crosswordName: crosswordName,
        CrosswordInfoFields.timestamp: timestamp.toIso8601String(),
        CrosswordInfoFields.userId: userId,
        CrosswordInfoFields.status: status,
      };

  CrosswordInfo copy({
    int? id,
    String? path,
    String? crosswordName,
    DateTime? timestamp,
    String? userId,
    String? status,
  }) =>
      CrosswordInfo(
        id: id ?? this.id,
        path: path ?? this.path,
        crosswordName: crosswordName ?? this.crosswordName,
        timestamp: timestamp ?? this.timestamp,
        userId: userId ?? this.userId,
        status: status ?? this.status,
      );

  @override
  String toString() {
    return 'Photo{id: $id, path: $path, crosswordName: $crosswordName, timestamp: $timestamp, userId: $userId, status: $status}';
  }

  static CrosswordInfo fromJson(Map<String, Object?> json) => CrosswordInfo(
      id: json[CrosswordInfoFields.id] as int,
      path: json[CrosswordInfoFields.path] as String,
      crosswordName: json[CrosswordInfoFields.crosswordName] as String,
      timestamp: DateTime.parse(json[CrosswordInfoFields.timestamp] as String),
      userId: json[CrosswordInfoFields.userId] as String,
      status: json[CrosswordInfoFields.status] as String);
}
