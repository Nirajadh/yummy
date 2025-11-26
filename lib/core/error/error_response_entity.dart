/// Domain-safe representation of validation errors from the API.
class ErrorResponse {
  final bool success;
  final String message;
  final List<String> errors;

  ErrorResponse({
    required this.success,
    required this.message,
    required this.errors,
  });
}
