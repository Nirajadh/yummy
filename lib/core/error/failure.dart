/// Lightweight failure wrapper for domain layers.
class Failure {
  final String message;

  Failure([this.message = 'An unexpected error occurred.']);
}
