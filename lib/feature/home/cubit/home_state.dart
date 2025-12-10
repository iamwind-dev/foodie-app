part of 'home_cubit.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Recipe> recipes;
  final List<Country> countries;
  final List<Recipe> suggestions;

  HomeLoaded({
    required this.recipes,
    required this.countries,
    required this.suggestions,
  });
}

class HomeError extends HomeState {
  final String message;

  HomeError(this.message);
}

// Models
class Recipe {
  final String id;
  final String name;
  final String imageUrl;

  Recipe({required this.id, required this.name, required this.imageUrl});
}

class Country {
  final String id;
  final String name;
  final String imageUrl;

  Country({required this.id, required this.name, required this.imageUrl});
}
