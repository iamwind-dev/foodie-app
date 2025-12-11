import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/recipe_cubit.dart';
import '../cubit/recipe_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

class RecipeScreen extends StatelessWidget {
  final Map<String, dynamic>? generatedRecipe;
  final String? mode;
  final String? imagePath;
  final String? imageUrl;

  const RecipeScreen({super.key, this.generatedRecipe, this.mode, this.imagePath, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    Map<String, dynamic>? passedRecipe;
    String? passedMode;
    String? passedImagePath;
    String? passedImageUrl;
    if (args is Map) {
      passedRecipe = (args['recipe'] is Map<String, dynamic>)
          ? Map<String, dynamic>.from(args['recipe'] as Map)
          : null;
      passedMode = args['mode']?.toString();
      passedImagePath = args['imagePath']?.toString();
      passedImageUrl = args['imageUrl']?.toString() ?? passedRecipe?['hinh_anh']?.toString() ?? passedRecipe?['image_url']?.toString();
    }

    return BlocProvider(
      create: (context) {
        final cubit = RecipeCubit(imagePath: imagePath ?? passedImagePath);
        final recipe = generatedRecipe ?? passedRecipe;
        if (recipe != null) {
          cubit.loadFromGenerated(recipe);
        } else {
          cubit.loadRecipe();
        }
        return cubit;
      },
      child: RecipeView(
        mode: mode ?? passedMode,
        imagePath: imagePath ?? passedImagePath,
        imageUrl: imageUrl ?? passedImageUrl,
      ),
    );
  }
}

class RecipeView extends StatefulWidget {
  final String? mode;
  final String? imagePath;
  final String? imageUrl;
  const RecipeView({super.key, this.mode, this.imagePath, this.imageUrl});

  @override
  State<RecipeView> createState() => _RecipeViewState();
}

class _RecipeViewState extends State<RecipeView> {
  bool _showAllIngredients = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: BlocBuilder<RecipeCubit, RecipeState>(
        builder: (context, state) {
          if (state is RecipeLoading) {
            return const AppLoadingWidget(message: 'Đang tải công thức...');
          }

          if (state is RecipeLoaded) {
            return _buildRecipeContent(context, state);
          }

          return const AppErrorWidget(
            title: 'Lỗi',
            message: 'Không thể tải công thức',
          );
        },
      ),
    );
  }

  Widget _buildRecipeContent(BuildContext context, RecipeLoaded state) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(context),
            _buildTitleBlock(state),
            const Divider(height: 24, thickness: 1, color: Color(0xFFE6E6E6)),
            _buildMetaSection(state),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                icon: Icons.egg_alt_rounded,
                title: 'Nguyên liệu',
              ),
            ),
            const SizedBox(height: 12),
            _buildIngredientsList(state.ingredients),
            if (state.utensils.isNotEmpty) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Dụng cụ',
                  iconGradient: AppColors.primaryGradient,
                ),
              ),
              const SizedBox(height: 12),
              _buildUtensilsList(state.utensils),
            ],
            if (state.preparationSteps.isNotEmpty) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  icon: Icons.soup_kitchen_rounded,
                  title: 'Các bước thực hiện',
                ),
              ),
              const SizedBox(height: 12),
              _buildPreparationSteps(state.preparationSteps),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final hasFileImage = widget.imagePath != null && widget.imagePath!.isNotEmpty;
    final hasUrlImage = widget.imageUrl != null && widget.imageUrl!.isNotEmpty;
    final hasImage = hasFileImage || hasUrlImage;
    if (hasImage) {
      return Stack(
        children: [
          _buildImageBanner(
            path: hasFileImage ? widget.imagePath! : null,
            url: hasUrlImage ? widget.imageUrl! : null,
          ),
          _buildTopBar(context, overlay: true),
        ],
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top + 8, 12, 0),
      child: _buildTopBar(context, overlay: false),
    );
  }

  Widget _buildImageBanner({String? path, String? url}) {
    return SizedBox(
      width: double.infinity,
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (path != null)
            Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackBanner(),
            )
          else if (url != null)
            Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackBanner(),
            )
          else
            _fallbackBanner(),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.05),
                  Colors.black.withOpacity(0.35),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackBanner() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.image_rounded, color: Colors.grey, size: 48),
    );
  }

  Widget _buildTopBar(BuildContext context, {required bool overlay}) {
    final bar = Row(
      children: [
        _circleButton(
          icon: Icons.arrow_back_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const Spacer(),
        _circleButton(
          icon: Icons.favorite_border_rounded,
          onTap: () => context.read<RecipeCubit>().toggleLike(),
        ),
        const SizedBox(width: 10),
        _circleButton(
          icon: Icons.more_vert_rounded,
          onTap: () {},
        ),
      ],
    );

    if (overlay) {
      return Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        left: 12,
        right: 12,
        child: bar,
      );
    }

    return bar;
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withOpacity(0.85),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildTitleBlock(RecipeLoaded state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaSection(RecipeLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Định lượng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _metaRow('Độ khó:', state.difficulty),
          _metaRow('Thời gian nấu:', state.time),
          _servingRow(state),
          _metaRow('Calories:', state.calories ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _servingRow(RecipeLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Khẩu phần:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          // _servingButton(
          //   icon: Icons.remove,
          //   onTap: () => context.read<RecipeCubit>().decrementServings(),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${state.servings}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          // _servingButton(
          //   icon: Icons.add,
          //   onTap: () => context.read<RecipeCubit>().incrementServings(),
          // ),
          const SizedBox(width: 6),
          const Text(
            'người',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsList(List<Ingredient> ingredients) {
    final displayed = _showAllIngredients ? ingredients : ingredients.take(5).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ...displayed.map((ingredient) {
            final hasQty = ingredient.quantity.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      ingredient.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    hasQty ? ingredient.quantity : '',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          if (ingredients.length > 5)
            TextButton.icon(
              onPressed: () => setState(() => _showAllIngredients = !_showAllIngredients),
              icon: Icon(_showAllIngredients ? Icons.expand_less : Icons.expand_more, size: 18),
              label: Text(_showAllIngredients ? 'Thu gọn' : 'Xem thêm'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUtensilsList(List<Utensil> utensils) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: utensils.map((utensil) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: Text(
                    utensil.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPreparationSteps(List<Instruction> steps) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value.step;
          return StepIndicator(
            stepNumber: index + 1,
            content: step,
            isLast: index == steps.length - 1,
          );
        }).toList(),
      ),
    );
  }
}
