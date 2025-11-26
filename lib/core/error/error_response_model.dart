/// Maps validation error payloads from the API.
class ErrorResponseModel {
  final bool success;
  final String message;
  final Map<String, List<String>> errors;

  ErrorResponseModel({
    required this.success,
    required this.message,
    required this.errors,
  });

  factory ErrorResponseModel.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'] as Map<String, dynamic>? ?? {};
    return ErrorResponseModel(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      errors: rawErrors.map(
        (key, value) => MapEntry(
          key,
          List<String>.from(
            (value as List).map((e) => e.toString()),
          ),
        ),
      ),
    );
  }
}
