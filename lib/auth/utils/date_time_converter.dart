import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

class DateTimeConverter implements JsonConverter<DateTime?, String?> {
  const DateTimeConverter();

  @override
  DateTime? fromJson(String? value) {
    if (value != null) {
      return DateTime.parse(value);
    }
    return null;
  }

  @override
  String? toJson(DateTime? object) {
    final inputFormat = DateFormat('yyyy-MM-dd');
    if (object != null) {
      return inputFormat.format(object);
    }
    return null;
  }
}
