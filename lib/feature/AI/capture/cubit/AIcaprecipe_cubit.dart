import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/repositories/recipe_repository.dart';
import 'AIcaprecipe_state.dart';

class AICaptureRecipeCubit extends Cubit<AICaptureRecipeState> {
  final ImagePicker _picker = ImagePicker();
  final RecipeRepository _recipeRepository;

  AICaptureRecipeCubit({
    RecipeRepository? recipeRepository,
  })  : _recipeRepository = recipeRepository ?? RecipeRepository(),
        super(AICaptureRecipeInitial());

  /// Capture image from device camera
  Future<void> captureImage() async {
    try {
      emit(AICaptureRecipeCapturing());

      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (file == null) {
        emit(const AICaptureRecipeError('Không có ảnh được chụp'));
        emit(AICaptureRecipeInitial());
        return;
      }

      emit(AICaptureRecipeCaptured(file.path));
    } catch (e) {
      emit(AICaptureRecipeError('Failed to capture image: ${e.toString()}'));
    }
  }

  /// Pick image from gallery
  Future<void> pickFromGallery() async {
    try {
      emit(AICaptureRecipeCapturing());

      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (file == null) {
        emit(const AICaptureRecipeError('Không có ảnh được chọn'));
        emit(AICaptureRecipeInitial());
        return;
      }

      emit(AICaptureRecipeCaptured(file.path));
    } catch (e) {
      emit(AICaptureRecipeError('Failed to pick image: ${e.toString()}'));
    }
  }

  /// Accept image path from external capture (e.g. camera preview)
  void onImageCaptured(String path) {
    emit(AICaptureRecipeCaptured(path));
  }

  Future<void> processImage(String imagePath) async {
    try {
      emit(AICaptureRecipeProcessing());
      final response = await _recipeRepository.generateRecipeFromImage(imagePath);

      final status = response['status']?.toString() ?? 'unknown';
      final message = response['message']?.toString() ?? 'Đã xử lý ảnh';
      final ingredientsDetected = <String>[];
      if (response['ingredients_detected'] is List) {
        for (final item in response['ingredients_detected']) {
          final text = item?.toString().trim();
          if (text != null && text.isNotEmpty) {
            ingredientsDetected.add(text);
          }
        }
      }

      Map<String, dynamic>? recipe;
      if (response['recipe'] is Map) {
        recipe = Map<String, dynamic>.from(response['recipe'] as Map);
      }

      if (status == 'no_ingredients') {
        emit(const AICaptureRecipeError('Không tìm thấy nguyên liệu trong ảnh, vui lòng chụp rõ hơn.'));
        emit(AICaptureRecipeInitial());
        return;
      }

      if (recipe == null) {
        emit(AICaptureRecipeError(
          message.isNotEmpty
              ? message
              : 'Nhận diện nguyên liệu thành công nhưng chưa tạo được công thức.',
        ));
        return;
      }

      emit(AICaptureRecipeSuccess(
        status: status,
        message: message,
        ingredientsDetected: ingredientsDetected,
        recipe: recipe,
        raw: Map<String, dynamic>.from(response),
      ));
    } catch (e) {
      emit(AICaptureRecipeError('Không tạo được công thức từ ảnh: ${e.toString()}'));
    }
  }

  void reset() {
    emit(AICaptureRecipeInitial());
  }

  void retryCapture() {
    emit(AICaptureRecipeInitial());
  }
}
