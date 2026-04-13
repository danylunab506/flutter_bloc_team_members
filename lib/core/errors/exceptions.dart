class DataParsingException implements Exception {
  final String message;

  const DataParsingException(this.message);

  @override
  String toString() => message;
}

class DataLoadException implements Exception {
  final String message;

  const DataLoadException(this.message);

  @override
  String toString() => message;
}
