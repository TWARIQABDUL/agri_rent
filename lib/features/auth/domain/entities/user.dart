import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? role;
  final bool emailVerified;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role,
    this.emailVerified = false,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    role,
    emailVerified,
  ];
}
