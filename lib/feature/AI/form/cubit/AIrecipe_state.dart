import 'package:equatable/equatable.dart';

abstract class AIRecipeState extends Equatable {
  const AIRecipeState();

  @override
  List<Object> get props => [];
}

class AIRecipeInitial extends AIRecipeState {}

class AIRecipeFormState extends AIRecipeState {
  final String description;
  final String ingredientsText;
  final List<String> selectedTags;
  
  const AIRecipeFormState({
    this.description = '',
    this.ingredientsText = '',
    this.selectedTags = const [],
  });
  
  @override
  List<Object> get props => [description, ingredientsText, selectedTags];
  
  AIRecipeFormState copyWith({
    String? description,
    String? ingredientsText,
    List<String>? selectedTags,
  }) {
    return AIRecipeFormState(
      description: description ?? this.description,
      ingredientsText: ingredientsText ?? this.ingredientsText,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }
}

class AIRecipeGenerating extends AIRecipeState {}

class AIRecipeSuccess extends AIRecipeState {
  final String mode;
  final Map<String, dynamic> recipe;
  final String raw;
  
  const AIRecipeSuccess({
    required this.mode,
    required this.recipe,
    required this.raw,
  });
  
  @override
  List<Object> get props => [mode, recipe, raw];
}

class AIRecipeError extends AIRecipeState {
  final String error;
  
  const AIRecipeError({required this.error});
  
  @override
  List<Object> get props => [error];
}
