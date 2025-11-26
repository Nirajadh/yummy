/// Shared exception types to keep network/data layer errors predictable.
class ServerException implements Exception {
  final String message;

  const ServerException(this.message);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;

  const NetworkException(this.message);

  @override
  String toString() => message;
}

class DataParsingException implements Exception {
  final String message;

  const DataParsingException(this.message);

  @override
  String toString() => message;
}
