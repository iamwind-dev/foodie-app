import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/repositories/recipe_repository.dart';
import 'AIrecipe_state.dart';

class AIRecipeCubit extends Cubit<AIRecipeState> {
  AIRecipeCubit({RecipeRepository? recipeRepository})
      : _recipeRepository = recipeRepository ?? RecipeRepository(),
        super(AIRecipeInitial());

  final RecipeRepository _recipeRepository;
  final List<String> availableTags = [
    'Món chay',
    'Ít calo',
    'Không cay',
    'Bữa sáng',
    'Nhanh gọn',
  ];

  void initialize() {
    emit(const AIRecipeFormState());
  }

  void updateDescription(String description) {
    if (state is AIRecipeFormState) {
      final currentState = state as AIRecipeFormState;
      emit(currentState.copyWith(description: description));
    }
  }

  void updateIngredientsText(String text) {
    if (state is AIRecipeFormState) {
      final currentState = state as AIRecipeFormState;
      emit(currentState.copyWith(ingredientsText: text));
    }
  }

  void toggleTag(String tag) {
    if (state is AIRecipeFormState) {
      final currentState = state as AIRecipeFormState;
      final newTags = List<String>.from(currentState.selectedTags);
      
      if (newTags.contains(tag)) {
        newTags.remove(tag);
      } else {
        newTags.add(tag);
      }
      
      emit(currentState.copyWith(selectedTags: newTags));
    }
  }

  Future<void> generateRecipe() async {
    if (state is! AIRecipeFormState) return;
    
    final formState = state as AIRecipeFormState;

    final description = formState.description.trim();
    final ingredients = _parseIngredients(formState.ingredientsText);

    if (description.isEmpty && ingredients.isEmpty) {
      emit(const AIRecipeError(error: 'Nhập mô tả món ăn hoặc danh sách nguyên liệu'));
      emit(formState);
      return;
    }

    if (description.isNotEmpty && ingredients.isNotEmpty) {
      emit(const AIRecipeError(error: 'Chỉ nhập 1 trong 2: mô tả HOẶC danh sách nguyên liệu'));
      emit(formState);
      return;
    }

    emit(AIRecipeGenerating());
    
    try {
      final result = await _recipeRepository.generateRecipe(
        description: description.isNotEmpty ? description : null,
        ingredients: ingredients.isNotEmpty ? ingredients : null,
      );

      final mode = result['mode']?.toString() ?? '';
      final recipe = (result['recipe'] is Map<String, dynamic>)
          ? Map<String, dynamic>.from(result['recipe'])
          : <String, dynamic>{};

      emit(AIRecipeSuccess(
        mode: mode,
        recipe: recipe,
        raw: const JsonEncoder.withIndent('  ').convert(result),
      ));
    } catch (e) {
      emit(AIRecipeError(error: e.toString()));
      emit(formState);
    }
  }

  List<String> _parseIngredients(String raw) {
    final parts = raw
        .split(RegExp(r'[,\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts;
  }
}
