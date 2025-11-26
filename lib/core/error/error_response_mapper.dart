import 'package:yummy/core/error/error_response_entity.dart';
import 'package:yummy/core/error/error_response_model.dart';

/// Flattens API error maps into a simple list for display.
class ErrorResponseMapper {
  static ErrorResponse toEntity(ErrorResponseModel model) {
    final allErrors = <String>[];

    model.errors.forEach((_, messages) {
      allErrors.addAll(messages);
    });

    return ErrorResponse(
      success: model.success,
      message: model.message,
      errors: allErrors,
    );
  }
}
