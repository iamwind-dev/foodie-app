import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterFormState extends RegisterState {
  final String firstname;
  final String lastname;
  final String age;
  final String gender;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isConfirmPasswordValid;

  const RegisterFormState({
    this.firstname = '',
    this.lastname = '',
    this.age = '',
    this.gender = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isEmailValid = true,
    this.isPasswordValid = true,
    this.isConfirmPasswordValid = true,
  });

  RegisterFormState copyWith({
    String? firstname,
    String? lastname,
    String? age,
    String? gender,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? isConfirmPasswordValid,
  }) {
    return RegisterFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isConfirmPasswordValid: isConfirmPasswordValid ?? this.isConfirmPasswordValid,
    );
  }

  bool get isFormValid =>
      email.isNotEmpty &&
      firstname.isNotEmpty &&
      lastname.isNotEmpty &&
      age.isNotEmpty &&
      gender.isNotEmpty &&
      password.isNotEmpty &&
      confirmPassword.isNotEmpty &&
      isEmailValid &&
      isPasswordValid &&
      isConfirmPasswordValid &&
      password == confirmPassword;

  @override
  List<Object?> get props => [
        firstname,
        lastname,
        age,
        gender,
        email,
        password,
        confirmPassword,
        isEmailValid,
        isPasswordValid,
        isConfirmPasswordValid,
      ];
}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {}

class RegisterError extends RegisterState {
  final String message;

  const RegisterError(this.message);

  @override
  List<Object?> get props => [message];
}
