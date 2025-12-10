import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'recipecreate_state.dart';
import '../../../core/repositories/favorite_repository.dart';
import '../../../core/services/storage_service.dart';

class RecipeCreateCubit extends Cubit<RecipeCreateState> {
  final ImagePicker _picker = ImagePicker();
  final FavoriteRepository _favoriteRepository;
  final StorageService _storageService;
  
  RecipeCreateCubit({FavoriteRepository? favoriteRepository, StorageService? storageService})
      : _favoriteRepository = favoriteRepository ?? FavoriteRepository(),
        _storageService = storageService ?? StorageService(),
        super(RecipeCreateInitial());

  void initialize() {
    emit(const RecipeCreateFormState());
  }

  void updateRecipeTitle(String title) {
    if (state is RecipeCreateFormState) {
      final currentState = state as RecipeCreateFormState;
      emit(currentState.copyWith(recipeTitle: title));
    }
  }

  void incrementServings() {
    if (state is RecipeCreateFormState) {
      final currentState = state as RecipeCreateFormState;
      emit(currentState.copyWith(servings: currentState.servings + 1));
    }
  }

  void decrementServings() {
    if (state is RecipeCreateFormState) {
      final currentState = state as RecipeCreateFormState;
      if (currentState.servings > 1) {
        emit(currentState.copyWith(servings: currentState.servings - 1));
      }
    }
  }

  void updatePrepTime(int minutes) {
    if (state is RecipeCreateFormState) {
      final currentState = state as RecipeCreateFormState;
      emit(currentState.copyWith(prepTime: minutes));
    }
  }

  void updateCookTime(int minutes) {
    if (state is RecipeCreateFormState) {
      final currentState = state as RecipeCreateFormState;
      emit(currentState.copyWith(cookTime: minutes));
    }
  }

  void addIngredient(String ingredient) {
    if (state is RecipeCreateFormState) {
      final currentState = state as RecipeCreateFormState;
      if (ingredient.isNotEmpty) {
        final newIngredients = List<String>.from(currentState.ingredients)..add(ingredient);
        emit(currentState.copyWith(ingredients: newIngredients));
      }
    }
  }

  void removeIngredient(int index) {
    if (state is RecipeCreateFormState) {
      final currentState = state as RecipeCreateFormState;
      final newIngredients = List<String>.from(currentState.ingredients)..removeAt(index);
      emit(currentState.copyWith(ingredients: newIngredients));
    }
  }

  void addUtensil(String utensil) {
    if (state is RecipeCreateFormState) {
      final currentState = state as RecipeCreateFormState;
      if (utensil.isNotEmpty) {
        final newUtensils = List<String>.from(currentState.utensils)..add(utensil);
        emit(currentState.copyWith(utensils: newUtensils));
      }
    }
  }

  void removeUtensil(int index) {
    if (state is RecipeCreateFormState) {
      final currentState = state as RecipeCreateFormState;
      final newUtensils = List<String>.from(currentState.utensils)..removeAt(index);
      emit(currentState.copyWith(utensils: newUtensils));
    }
  }

  void addPreparationStep(String step) {
    if (state is RecipeCreateFormState) {
      final currentState = state as RecipeCreateFormState;
      if (step.isNotEmpty) {
        final newSteps = List<String>.from(currentState.preparationSteps)..add(step);
        emit(currentState.copyWith(preparationSteps: newSteps));
      }
    }
  }

  void removePreparationStep(int index) {
    if (state is RecipeCreateFormState) {
      final currentState = state as RecipeCreateFormState;
      final newSteps = List<String>.from(currentState.preparationSteps)..removeAt(index);
      emit(currentState.copyWith(preparationSteps: newSteps));
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        updatePhoto(image.path);
      }
    } catch (e) {
      // Handle error silently or emit error state if needed
      print('Error picking image: $e');
    }
  }

  void updatePhoto(String path) {
    if (state is RecipeCreateFormState) {
      final currentState = state as RecipeCreateFormState;
      emit(currentState.copyWith(photoPath: path));
    }
  }

  Future<void> createRecipe() async {
    if (state is! RecipeCreateFormState) return;
    
    final formState = state as RecipeCreateFormState;
    
    if (formState.recipeTitle.isEmpty) {
      emit(const RecipeCreateError(error: 'Recipe title is required'));
      emit(formState);
      return;
    }

    if (formState.ingredients.isEmpty) {
      emit(const RecipeCreateError(error: 'At least one ingredient is required'));
      emit(formState);
      return;
    }

    if (formState.preparationSteps.isEmpty) {
      emit(const RecipeCreateError(error: 'At least one preparation step is required'));
      emit(formState);
      return;
    }

    emit(RecipeCreateLoading());
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      String? imageUrl;
      if (formState.photoPath != null && formState.photoPath!.isNotEmpty) {
        imageUrl = await _storageService.uploadRecipeImage(formState.photoPath!);
      }

      // Build recipe payload to save as favorite
      final data = {
        'name': formState.recipeTitle,
        'ingredients': formState.ingredients.map((e) => {'name': e, 'quantity': ''}).toList(),
        'tools': formState.utensils,
        'instructions': formState.preparationSteps,
        'estimated_time': (formState.prepTime + formState.cookTime).toString(),
        'servings': formState.servings,
        'mode': 'created',
      };

      await _favoriteRepository.saveFavorite(
        title: formState.recipeTitle,
        time: (formState.prepTime + formState.cookTime).toString(),
        calories: null,
        mode: 'created',
        imageUrl: imageUrl,
        data: data,
      );

      emit(const RecipeCreateSuccess(message: 'Recipe created successfully!'));
    } catch (e) {
      emit(RecipeCreateError(error: e.toString()));
      emit(formState);
    }
  }
}
