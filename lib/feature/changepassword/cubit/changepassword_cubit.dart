import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/auth_repository.dart';
import 'changepassword_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final AuthRepository _authRepository;

  ChangePasswordCubit({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository(),
        super(ChangePasswordInitial());

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    // Validation
    if (currentPassword.isEmpty) {
      emit(const ChangePasswordError('Current password is required'));
      return;
    }

    if (newPassword.isEmpty) {
      emit(const ChangePasswordError('New password is required'));
      return;
    }

    if (newPassword.length < 6) {
      emit(const ChangePasswordError('New password must be at least 6 characters'));
      return;
    }

    if (newPassword != confirmPassword) {
      emit(const ChangePasswordError('Passwords do not match'));
      return;
    }

    if (currentPassword == newPassword) {
      emit(const ChangePasswordError('New password must be different from current password'));
      return;
    }

    emit(ChangePasswordLoading());

    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      
      emit(const ChangePasswordSuccess());
    } catch (e) {
      emit(ChangePasswordError(e.toString()));
    }
  }

  void reset() {
    emit(ChangePasswordInitial());
  }
}
