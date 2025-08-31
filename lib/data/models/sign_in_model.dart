// lib/models/sign_in_model.dart
import 'dart:convert';

class SignInModel {
  final String email;
  final String password;

  const SignInModel({
    required this.email,
    required this.password,
  });

  // ---- validation ----
  bool get isValidEmail =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  bool get isValidPassword => password.length >= 6;

  // ---- serialization ----
  Map<String, dynamic> toMap() => {
    'email': email,
    'password': password,
  };

  factory SignInModel.fromMap(Map<String, dynamic> map) => SignInModel(
    email: map['email'] ?? '',
    password: map['password'] ?? '',
  );

  String toJson() => json.encode(toMap());
  factory SignInModel.fromJson(String source) =>
      SignInModel.fromMap(json.decode(source));

  // ---- copy ----
  SignInModel copyWith({String? email, String? password}) => SignInModel(
    email: email ?? this.email,
    password: password ?? this.password,
  );
}
