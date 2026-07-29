/// An error that already carries a message fit to show a user.
///
/// Data sources throw infrastructure errors; repositories translate them into
/// this type so blocs and widgets never have to interpret a Firebase code.
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}
