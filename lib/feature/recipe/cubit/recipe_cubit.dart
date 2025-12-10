import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/favorite_repository.dart';
import 'recipe_state.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final FavoriteRepository _favoriteRepository;
  final String? imagePath;

  RecipeCubit({FavoriteRepository? favoriteRepository, this.imagePath})
      : _favoriteRepository = favoriteRepository ?? FavoriteRepository(),
        super(RecipeInitial());

  Future<void> loadRecipe() async {
    emit(RecipeLoading());
    try {
      // Simulate loading recipe data
      await Future.delayed(const Duration(milliseconds: 500));
      emit(RecipeLoaded(
        title: 'Pancake',
        time: '10 minutes',
        difficulty: 'Easy',
        price: 'Cheap',
        servings: 2,
        ingredients: const [
          Ingredient(name: 'Flour', quantity: '300g', icon: 'flour'),
          Ingredient(name: 'Eggs', quantity: '3', icon: 'egg'),
          Ingredient(name: 'Sugar', quantity: '3 tbsp.', icon: null),
          Ingredient(name: 'Butter', quantity: '50g', icon: null),
          Ingredient(name: 'Milk', quantity: '60cl', icon: 'milk'),
        ],
        utensils: const [
          Utensil(name: 'Whip', icon: 'whisk'),
          Utensil(name: 'Bowl', icon: 'bowl'),
          Utensil(name: 'Suspicious', icon: 'ladle'),
          Utensil(name: 'Stove', icon: 'pan'),
        ],
        preparationSteps: const [
          Instruction(step: 'Put the flour in the bowl and make a well in the center.'),
          Instruction(step: 'Add the whole eggs, sugar, oil and butter.'),
          Instruction(step: 'Gently whisk together, gradually adding the milk. The resulting paste should have the consistency of a slightly thick liquid.'),
          Instruction(step: 'Heat a non-stick pan and lightly oil it with a paper towel. Pour in a ladleful of batter, spread it evenly in the pan, and wait until it\'s cooked on one side before flipping it. Cook all the pancakes this way over low heat.'),
        ],
        rawData: null,
      ));
    } catch (e) {
      emit(RecipeError(error: e.toString()));
    }
  }

  Future<void> loadFromGenerated(Map<String, dynamic> recipe) async {
    emit(RecipeLoading());
    try {
      final title = recipe['name']?.toString() ?? 'AI Recipe';
      final servings = (recipe['servings'] is int)
          ? recipe['servings'] as int
          : int.tryParse('${recipe['servings']}') ?? 1;
      final time = recipe['estimated_time']?.toString() ??
          recipe['cooking_time']?.toString() ??
          recipe['cook_time']?.toString() ??
          'N/A';
      final calories = recipe['calories']?.toString();
      final ingredientsRaw = recipe['ingredients'];
      final stepsRaw = recipe['steps'] ?? recipe['instructions'];
      final toolsRaw = recipe['tools'] ?? recipe['utensils'];

      final ingredients = <Ingredient>[];
      if (ingredientsRaw is List) {
        for (final item in ingredientsRaw) {
          if (item is Map) {
            final name = item['name']?.toString() ?? '';
            final qty = item['quantity']?.toString() ?? '';
            if (name.isNotEmpty || qty.isNotEmpty) {
              ingredients.add(Ingredient(name: name, quantity: qty, icon: null));
            }
          } else {
            final text = item?.toString() ?? '';
            if (text.isNotEmpty) {
              ingredients.add(Ingredient(name: text, quantity: '', icon: null));
            }
          }
        }
      }

      final steps = <Instruction>[];
      if (stepsRaw is List) {
        for (final s in stepsRaw) {
          final text = s?.toString() ?? '';
          if (text.isNotEmpty) steps.add(Instruction(step: text));
        }
      }

      final utensils = <Utensil>[];
      if (toolsRaw is List) {
        for (final t in toolsRaw) {
          final name = t?.toString() ?? '';
          if (name.isNotEmpty) {
            utensils.add(Utensil(name: name, icon: null));
          }
        }
      }

      emit(RecipeLoaded(
        title: title,
        time: time,
        difficulty: 'N/A',
        price: 'N/A',
        servings: servings > 0 ? servings : 1,
        ingredients: ingredients.isNotEmpty
            ? ingredients
            : [const Ingredient(name: 'Đang cập nhật', quantity: '', icon: null)],
        utensils: utensils,
        preparationSteps: steps.isNotEmpty
            ? steps
            : [const Instruction(step: 'Đang cập nhật bước chế biến')],
        calories: calories,
        mode: recipe['mode']?.toString(),
        rawData: Map<String, dynamic>.from(recipe),
      ));
    } catch (e) {
      emit(RecipeError(error: e.toString()));
    }
  }
  
  void toggleLike() {
    if (state is! RecipeLoaded) return;
    final currentState = state as RecipeLoaded;
    final newLiked = !currentState.isLiked;
    emit(currentState.copyWith(isLiked: newLiked));

    if (newLiked) {
      _favoriteRepository.saveFavorite(
        title: currentState.title,
        time: currentState.time,
        calories: currentState.calories,
        mode: currentState.mode,
        imageUrl: imagePath ?? currentState.rawData?['image_url']?.toString(),
        data: currentState.rawData ?? _toMap(currentState),
      );
    }
  }

  Map<String, dynamic> _toMap(RecipeLoaded r) {
    return {
      'name': r.title,
      'estimated_time': r.time,
      'calories': r.calories,
      'mode': r.mode,
      'ingredients': r.ingredients
          .map((e) => {'name': e.name, 'quantity': e.quantity})
          .toList(),
      'tools': r.utensils.map((e) => e.name).toList(),
      'instructions': r.preparationSteps.map((e) => e.step).toList(),
      'servings': r.servings,
    };
  }
  
  void incrementServings() {
    if (state is RecipeLoaded) {
      final currentState = state as RecipeLoaded;
      emit(currentState.copyWith(servings: currentState.servings + 1));
    }
  }
  
  void decrementServings() {
    if (state is RecipeLoaded) {
      final currentState = state as RecipeLoaded;
      if (currentState.servings > 1) {
        emit(currentState.copyWith(servings: currentState.servings - 1));
      }
    }
  }
}

