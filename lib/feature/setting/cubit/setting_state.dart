import 'package:equatable/equatable.dart';

abstract class SettingState extends Equatable {
  const SettingState();

  @override
  List<Object?> get props => [];
}

class SettingInitial extends SettingState {}

class SettingLoaded extends SettingState {
  final bool isDarkMode;
  final String language;

  const SettingLoaded({
    this.isDarkMode = false,
    this.language = 'Tiếng Việt',
  });

  SettingLoaded copyWith({
    bool? isDarkMode,
    String? language,
  }) {
    return SettingLoaded(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [isDarkMode, language];
}

class SettingLogoutLoading extends SettingState {}

class SettingLogoutSuccess extends SettingState {}

class SettingError extends SettingState {
  final String message;

  const SettingError(this.message);

  @override
  List<Object?> get props => [message];
}
