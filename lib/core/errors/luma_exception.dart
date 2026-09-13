class LumaException implements Exception {
  const LumaException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
