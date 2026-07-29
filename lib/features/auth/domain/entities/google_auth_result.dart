import 'package:equatable/equatable.dart';
import 'user.dart';

/// The outcome of a Google sign-in call. `isNewUser` tells the presentation
/// layer whether it still needs to collect a role before the Firestore
/// profile can be written.
class GoogleAuthResult extends Equatable {
  final User user;
  final bool isNewUser;
  final bool profilePersisted;

  const GoogleAuthResult({
    required this.user,
    required this.isNewUser,
    required this.profilePersisted,
  });

  @override
  List<Object?> get props => [user, isNewUser, profilePersisted];
}
