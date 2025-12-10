import 'package:equatable/equatable.dart';

abstract class RecipeCreateState extends Equatable {
  const RecipeCreateState();

  @override
  List<Object> get props => [];
}

class RecipeCreateInitial extends RecipeCreateState {}

class RecipeCreateLoading extends RecipeCreateState {}

class RecipeCreateFormState extends RecipeCreateState {
  final String recipeTitle;
  final int servings;
  final int prepTime;
  final int cookTime;
  final List<String> ingredients;
  final List<String> utensils;
  final List<String> preparationSteps;
  final String? photoPath;
  
  const RecipeCreateFormState({
    this.recipeTitle = '',
    this.servings = 2,
    this.prepTime = 0,
    this.cookTime = 0,
    this.ingredients = const [],
    this.utensils = const [],
    this.preparationSteps = const [],
    this.photoPath,
  });
  
  int get totalTime => prepTime + cookTime;
  
  @override
  List<Object> get props => [
    recipeTitle,
    servings,
    prepTime,
    cookTime,
    ingredients,
    utensils,
    preparationSteps,
    photoPath ?? '',
  ];
  
  RecipeCreateFormState copyWith({
    String? recipeTitle,
    int? servings,
    int? prepTime,
    int? cookTime,
    List<String>? ingredients,
    List<String>? utensils,
    List<String>? preparationSteps,
    String? photoPath,
  }) {
    return RecipeCreateFormState(
      recipeTitle: recipeTitle ?? this.recipeTitle,
      servings: servings ?? this.servings,
      prepTime: prepTime ?? this.prepTime,
      cookTime: cookTime ?? this.cookTime,
      ingredients: ingredients ?? this.ingredients,
      utensils: utensils ?? this.utensils,
      preparationSteps: preparationSteps ?? this.preparationSteps,
      photoPath: photoPath ?? this.photoPath,
    );
  }
}

class RecipeCreateSuccess extends RecipeCreateState {
  final String message;
  
  const RecipeCreateSuccess({required this.message});
  
  @override
  List<Object> get props => [message];
}

class RecipeCreateError extends RecipeCreateState {
  final String error;
  
  const RecipeCreateError({required this.error});
  
  @override
  List<Object> get props => [error];
}
