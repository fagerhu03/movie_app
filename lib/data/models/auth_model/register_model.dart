// lib/models/register_model.dart
import 'dart:convert';

class RegisterModel {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;
  final String avatarSeed;

  const RegisterModel({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phone,
    required this.avatarSeed,
  });

  // ---- validation ----
  bool get isValidName => name.trim().isNotEmpty;
  bool get isValidEmail =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  bool get isValidPassword => password.length >= 6;
  bool get passwordsMatch => password == confirmPassword;
  bool get isValidPhone =>
      phone.isEmpty || RegExp(r'^\+?[0-9]{7,15}$').hasMatch(phone);

  // ---- serialization ----
  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'password': password, // ⚠️ don’t store plain text in Firestore!
    'confirmPassword': confirmPassword,
    'phone': phone,
    'avatarSeed': avatarSeed,
  };

  factory RegisterModel.fromMap(Map<String, dynamic> map) => RegisterModel(
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    password: map['password'] ?? '',
    confirmPassword: map['confirmPassword'] ?? '',
    phone: map['phone'] ?? '',
    avatarSeed: map['avatarSeed'] ?? 'user_default',
  );

  String toJson() => json.encode(toMap());
  factory RegisterModel.fromJson(String source) =>
      RegisterModel.fromMap(json.decode(source));

  // ---- copy ----
  RegisterModel copyWith({
    String? name,
    String? email,
    String? password,
    String? confirmPassword,
    String? phone,
    String? avatarSeed,
  }) {
    return RegisterModel(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      phone: phone ?? this.phone,
      avatarSeed: avatarSeed ?? this.avatarSeed,
    );
  }
}
