import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;

  const User({
    required this.id,
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [id, name, email];
}

class Token extends Equatable {
  final String value;
  final DateTime expiresAt;

  const Token({
    required this.value,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [value, expiresAt];
}

class AuthSession extends Equatable {
  final User user;
  final Token token;

  const AuthSession({
    required this.user,
    required this.token,
  });

  bool get isValid => !token.isExpired;

  @override
  List<Object?> get props => [user, token];
}
