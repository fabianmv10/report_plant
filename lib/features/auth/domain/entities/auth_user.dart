import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

@freezed
class AuthUser with _$AuthUser {
  const factory AuthUser({
    required String id,
    required String username,
    required String email,
    String? displayName,
    List<String>? roles,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);
}

@freezed
class AuthToken with _$AuthToken {
  const factory AuthToken({
    required String accessToken,
    required String tokenType,
    required int expiresIn,
    String? refreshToken,
  }) = _AuthToken;

  factory AuthToken.fromJson(Map<String, dynamic> json) => _$AuthTokenFromJson(json);
}
