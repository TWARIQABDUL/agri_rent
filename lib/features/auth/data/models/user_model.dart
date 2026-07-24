import 'package:firebase_auth/firebase_auth.dart' as fb;
import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.role,
  });

  factory UserModel.fromFirebaseUser(fb.User user, {String? role}) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      role: role,
    );
  }
}
