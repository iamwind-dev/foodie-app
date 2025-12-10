import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/models/auth_response.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;
  
  LoginCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    
    if (email.isEmpty || password.isEmpty) {
      emit(LoginFailure('Email và mật khẩu không được để trống'));
      return;
    }
    if (!email.contains('@')) {
      emit(LoginFailure('Email không hợp lệ'));
      return;
    }
    
    try {
      final auth = await _authRepository.login(email: email, password: password);
      emit(LoginSuccess(auth.user));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(LoginLoading());
    emit(LoginFailure('Google login chưa được hỗ trợ'));
  }

  void reset() {
    emit(LoginInitial());
  }
}
