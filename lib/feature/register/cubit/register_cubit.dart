import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/auth_repository.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;
  
  RegisterCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(RegisterInitial()) {
    emit(const RegisterFormState());
  }

  void updateFirstName(String value) {
    if (state is RegisterFormState) {
      emit((state as RegisterFormState).copyWith(firstname: value));
    }
  }

  void updateLastName(String value) {
    if (state is RegisterFormState) {
      emit((state as RegisterFormState).copyWith(lastname: value));
    }
  }

  void updateAge(String value) {
    if (state is RegisterFormState) {
      emit((state as RegisterFormState).copyWith(age: value));
    }
  }

  void updateGender(String value) {
    if (state is RegisterFormState) {
      emit((state as RegisterFormState).copyWith(gender: value));
    }
  }

  void updateEmail(String email) {
    if (state is RegisterFormState) {
      final currentState = state as RegisterFormState;
      final isValid = _isValidEmail(email);
      emit(currentState.copyWith(
        email: email,
        isEmailValid: isValid,
      ));
    }
  }

  void updatePassword(String password) {
    if (state is RegisterFormState) {
      final currentState = state as RegisterFormState;
      final isValid = password.length >= 6;
      emit(currentState.copyWith(
        password: password,
        isPasswordValid: isValid,
      ));
    }
  }

  void updateConfirmPassword(String confirmPassword) {
    if (state is RegisterFormState) {
      final currentState = state as RegisterFormState;
      final isValid = confirmPassword == currentState.password && confirmPassword.isNotEmpty;
      emit(currentState.copyWith(
        confirmPassword: confirmPassword,
        isConfirmPasswordValid: isValid,
      ));
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> register() async {
    if (state is! RegisterFormState) return;

    final formState = state as RegisterFormState;
    
    if (!formState.isFormValid) {
      emit(const RegisterError('Vui lòng nhập đầy đủ thông tin hợp lệ'));
      emit(formState);
      return;
    }

    if (formState.password != formState.confirmPassword) {
      emit(const RegisterError('Mật khẩu không khớp'));
      emit(formState);
      return;
    }

    try {
      emit(RegisterLoading());
      await _authRepository.register(
        email: formState.email,
        password: formState.password,
        firstname: formState.firstname,
        lastname: formState.lastname,
        age: int.tryParse(formState.age),
        gender: formState.gender,
      );
      emit(RegisterSuccess());
    } catch (e) {
      emit(RegisterError(e.toString()));
      emit(formState);
    }
  }

  void reset() {
    emit(const RegisterFormState());
  }
}
