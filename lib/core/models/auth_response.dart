/// Auth response model matching FastAPI backend
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String? expiresAt;
  final UserData user;
  
  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
    this.expiresAt,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String? ?? json['token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      expiresAt: json['expires_at'] as String?,
      user: UserData.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
  
  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'token_type': tokenType,
        if (expiresAt != null) 'expires_at': expiresAt,
        'user': user.toJson(),
      };
}

class UserData {
  final String id;
  final String email;
  final String? firstname;
  final String? lastname;
  final int? age;
  final String? gender;
  final String? role;
  final String? avatar;
  final String? createdAt;
  
  UserData({
    required this.id,
    required this.email,
    this.firstname,
    this.lastname,
    this.age,
    this.gender,
    this.role,
    this.avatar,
    this.createdAt,
  });
  
  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: (json['id'] ?? json['user_id'] ?? '') as String,
      email: json['email'] as String? ?? '',
      firstname: json['firstname'] as String?,
      lastname: json['lastname'] as String?,
      age: json['age'] is int ? json['age'] as int : int.tryParse('${json['age']}'),
      gender: json['gender'] as String?,
      role: json['role'] as String?,
      avatar: json['avatar'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        if (firstname != null) 'firstname': firstname,
        if (lastname != null) 'lastname': lastname,
        if (age != null) 'age': age,
        if (gender != null) 'gender': gender,
        if (role != null) 'role': role,
        if (avatar != null) 'avatar': avatar,
        if (createdAt != null) 'created_at': createdAt,
      };
}
