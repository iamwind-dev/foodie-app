import 'package:flutter_bloc/flutter_bloc.dart';
import 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  SettingCubit() : super(SettingInitial()) {
    loadSettings();
  }

  void loadSettings() {
    emit(const SettingLoaded());
  }

  void toggleDarkMode() {
    if (state is SettingLoaded) {
      final currentState = state as SettingLoaded;
      emit(currentState.copyWith(isDarkMode: !currentState.isDarkMode));
    }
  }

  void changeLanguage(String language) {
    if (state is SettingLoaded) {
      final currentState = state as SettingLoaded;
      emit(currentState.copyWith(language: language));
    }
  }

  Future<void> logout() async {
    try {
      emit(SettingLogoutLoading());
      // Simulate logout API call
      await Future.delayed(const Duration(seconds: 1));
      emit(SettingLogoutSuccess());
    } catch (e) {
      emit(SettingError(e.toString()));
    }
  }

  void navigateToEditProfile() {
    // Navigate to edit profile screen
  }

  void navigateToChangePassword() {
    // Navigate to change password screen
  }

  void navigateToNotifications() {
    // Navigate to notifications screen
  }

  void navigateToFAQ() {
    // Navigate to FAQ screen
  }

  void navigateToContactSupport() {
    // Navigate to contact support screen
  }

  void navigateToAbout() {
    // Navigate to about screen
  }

  void navigateToTerms() {
    // Navigate to terms of service screen
  }
}
