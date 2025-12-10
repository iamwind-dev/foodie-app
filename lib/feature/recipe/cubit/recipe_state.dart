import 'package:equatable/equatable.dart';

class Ingredient {
  final String name;
  final String quantity;
  final String? icon;
  
  const Ingredient({
    required this.name,
    required this.quantity,
    this.icon,
  });
}

class Instruction {
  final String step;
  const Instruction({required this.step});
}

class Utensil {
  final String name;
  final String? icon;
  
  const Utensil({
    required this.name,
    this.icon,
  });
}

abstract class RecipeState extends Equatable {
  const RecipeState();

  @override
  List<Object> get props => [];
}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeLoaded extends RecipeState {
  final String title;
  final String time;
  final String difficulty;
  final String price;
  final int servings;
  final List<Ingredient> ingredients;
  final List<Utensil> utensils;
  final List<Instruction> preparationSteps;
  final String? calories;
  final String? mode;
  final bool isLiked;
  final Map<String, dynamic>? rawData;
  
  const RecipeLoaded({
    required this.title,
    required this.time,
    required this.difficulty,
    required this.price,
    required this.servings,
    required this.ingredients,
    required this.utensils,
    required this.preparationSteps,
    this.calories,
    this.mode,
    this.isLiked = false,
    this.rawData,
  });
  
  @override
  List<Object> get props => [
    title,
    time,
    difficulty,
    price,
    servings,
    ingredients,
    utensils,
    preparationSteps,
    calories ?? '',
    mode ?? '',
    isLiked,
    rawData ?? {},
  ];
  
  RecipeLoaded copyWith({
    String? title,
    String? time,
    String? difficulty,
    String? price,
    int? servings,
    List<Ingredient>? ingredients,
    List<Utensil>? utensils,
    List<Instruction>? preparationSteps,
    String? calories,
    String? mode,
    bool? isLiked,
    Map<String, dynamic>? rawData,
  }) {
    return RecipeLoaded(
      title: title ?? this.title,
      time: time ?? this.time,
      difficulty: difficulty ?? this.difficulty,
      price: price ?? this.price,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      utensils: utensils ?? this.utensils,
      preparationSteps: preparationSteps ?? this.preparationSteps,
      calories: calories ?? this.calories,
      mode: mode ?? this.mode,
      isLiked: isLiked ?? this.isLiked,
      rawData: rawData ?? this.rawData,
    );
  }
}

class RecipeError extends RecipeState {
  final String error;
  
  const RecipeError({required this.error});
  
  @override
  List<Object> get props => [error];
}
