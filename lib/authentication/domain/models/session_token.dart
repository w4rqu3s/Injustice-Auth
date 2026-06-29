import 'package:equatable/equatable.dart';

enum AuthProvider {
  firebase,
  google,
  facebook;

  /// Retorna o nome como string (ex: 'google')
  String get name => toString().split('.').last;

  /// Converte string para enum, útil ao restaurar do storage
  static AuthProvider fromString(String value) {
    return AuthProvider.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AuthProvider.firebase,
    );
  }
}

class SessionToken extends Equatable {
  final String uid;
  final String value;
  final String? name;
  final String? email;
  final DateTime expiresAt;
  final String? refreshToken;
  final AuthProvider provider;

  const SessionToken({
    required this.uid,
    required this.value,
    required this.expiresAt,
    required this.provider,
    this.refreshToken,
    this.name,
    this.email,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Serializa para JSON
 Map<String, dynamic> toJson() => {
        'uid': uid,
        'value': value,
        'name': name,
        'email': email,
        'expiresAt': expiresAt.toIso8601String(),
        'refreshToken': refreshToken,
        'provider': provider.name,
      };

  /// Constrói a partir do JSON
  /// Deserializa JSON para SessionToken
  factory SessionToken.fromJson(Map<String, dynamic> json) => SessionToken(
        uid: json['uid'] as String,
        value: json['value'] as String,
        name: json['name'] as String?,
        email: json['email'] as String?,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        refreshToken: json['refreshToken'] as String?,
        provider: AuthProvider.fromString(json['provider'] as String? ?? 'firebase'),
      );

  @override
  List<Object?> get props => [value, expiresAt, provider];
}
