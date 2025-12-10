import 'package:equatable/equatable.dart';

abstract class AICaptureRecipeState extends Equatable {
  const AICaptureRecipeState();

  @override
  List<Object?> get props => [];
}

class AICaptureRecipeInitial extends AICaptureRecipeState {}

class AICaptureRecipeCapturing extends AICaptureRecipeState {}

class AICaptureRecipeCaptured extends AICaptureRecipeState {
  final String imagePath;

  const AICaptureRecipeCaptured(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class AICaptureRecipeProcessing extends AICaptureRecipeState {}

class AICaptureRecipeSuccess extends AICaptureRecipeState {
  final String status;
  final String message;
  final List<String> ingredientsDetected;
  final Map<String, dynamic>? recipe;
  final Map<String, dynamic>? raw;

  const AICaptureRecipeSuccess({
    required this.status,
    required this.message,
    required this.ingredientsDetected,
    this.recipe,
    this.raw,
  });

  @override
  List<Object?> get props => [status, message, ingredientsDetected, recipe, raw];
}

class AICaptureRecipeError extends AICaptureRecipeState {
  final String message;

  const AICaptureRecipeError(this.message);

  @override
  List<Object?> get props => [message];
}
