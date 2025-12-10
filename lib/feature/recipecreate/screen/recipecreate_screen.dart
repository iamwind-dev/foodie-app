import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/recipecreate_cubit.dart';
import '../cubit/recipecreate_state.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../../core/constants/app_routes.dart';

class RecipeCreateScreen extends StatelessWidget {
  const RecipeCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecipeCreateCubit()..initialize(),
      child: const RecipeCreateView(),
    );
  }
}

class RecipeCreateView extends StatefulWidget {
  const RecipeCreateView({super.key});

  @override
  State<RecipeCreateView> createState() => _RecipeCreateViewState();
}

class _RecipeCreateViewState extends State<RecipeCreateView> with SingleTickerProviderStateMixin {
  int _currentNavIndex = 3; // Create tab
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 3) return; // Already on create
    setState(() {
      _currentNavIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAFAF1),
      body: BlocListener<RecipeCreateCubit, RecipeCreateState>(
        listener: (context, state) {
          if (state is RecipeCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Text(state.message),
                  ],
                ),
                backgroundColor: const Color(0xFF2ECC71),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
            Navigator.pop(context);
          } else if (state is RecipeCreateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(state.error)),
                  ],
                ),
                backgroundColor: const Color(0xFFE74C3C),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(),
            // Content
            Expanded(
              child: BlocBuilder<RecipeCreateCubit, RecipeCreateState>(
                builder: (context, state) {
                  if (state is RecipeCreateLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2ECC71).withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const CircularProgressIndicator(
                              color: Color(0xFF2ECC71),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Đang tạo công thức...',
                            style: TextStyle(
                              color: const Color(0xFF636E72).withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is! RecipeCreateFormState) {
                    return const SizedBox();
                  }

                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Hero Image Section
                          _buildHeroSection(context, state),
                          // Main Content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Recipe Title
                                _buildTitleSection(context, state),
                                const SizedBox(height: 20),
                                // Time Info Cards
                                _buildTimeCards(state),
                                const SizedBox(height: 24),
                                // Servings Counter
                                _buildServingsCard(context, state),
                                const SizedBox(height: 24),
                                // Utensils Section
                                _buildSectionCard(
                                  context: context,
                                  icon: Icons.kitchen_rounded,
                                  title: 'Dụng cụ',
                                  subtitle: '${state.utensils.length} món',
                                  items: state.utensils,
                                  emptyText: 'Thêm dụng cụ cần thiết',
                                  onAdd: () => _showAddDialog(
                                    context,
                                    'Thêm dụng cụ',
                                    'Tên dụng cụ',
                                    (value) => context.read<RecipeCreateCubit>().addUtensil(value),
                                  ),
                                  onRemove: (index) => context.read<RecipeCreateCubit>().removeUtensil(index),
                                ),
                                const SizedBox(height: 16),
                                // Ingredients Section
                                _buildSectionCard(
                                  context: context,
                                  icon: Icons.eco_rounded,
                                  title: 'Nguyên liệu',
                                  subtitle: '${state.ingredients.length} món',
                                  items: state.ingredients,
                                  emptyText: 'Thêm nguyên liệu',
                                  color: const Color(0xFFF39C12),
                                  onAdd: () => _showAddDialog(
                                    context,
                                    'Thêm nguyên liệu',
                                    'Tên nguyên liệu',
                                    (value) => context.read<RecipeCreateCubit>().addIngredient(value),
                                  ),
                                  onRemove: (index) => context.read<RecipeCreateCubit>().removeIngredient(index),
                                ),
                                const SizedBox(height: 16),
                                // Preparation Steps Section
                                _buildSectionCard(
                                  context: context,
                                  icon: Icons.format_list_numbered_rounded,
                                  title: 'Các bước thực hiện',
                                  subtitle: '${state.preparationSteps.length} bước',
                                  items: state.preparationSteps,
                                  emptyText: 'Thêm bước thực hiện',
                                  isNumbered: true,
                                  onAdd: () => _showAddDialog(
                                    context,
                                    'Thêm bước',
                                    'Mô tả bước thực hiện',
                                    (value) => context.read<RecipeCreateCubit>().addPreparationStep(value),
                                  ),
                                  onRemove: (index) => context.read<RecipeCreateCubit>().removePreparationStep(index),
                                ),
                                const SizedBox(height: 32),
                                // Create Button
                                _buildCreateButton(context),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Bottom Navigation
            // BottomNavigation(
            //   currentIndex: _currentNavIndex,
            //   onTap: _onNavTap,
            //   onShoppingList: () => Navigator.pushNamed(context, AppRoutes.shoppingList),
            //   onScanRecipe: () => Navigator.pushNamed(context, AppRoutes.aiCaptureRecipe),
            //   onCreateRecipe: () {}, // Already here
            //   onGenerateRecipe: () => Navigator.pushNamed(context, AppRoutes.aiRecipe),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFCAFCDF),
            Color(0xFFB8F5D0),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            children: [
              // Back button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF2ECC71),
                      size: 22,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Title
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      color: Color(0xFF2ECC71),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Tạo công thức',
                      style: TextStyle(
                        color: Color(0xFF2D3436),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const SizedBox(width: 44), // Balance
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, RecipeCreateFormState state) {
    return GestureDetector(
      onTap: () => context.read<RecipeCreateCubit>().pickImage(),
      child: Container(
        height: 200,
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Image or Placeholder
              Positioned.fill(
                child: state.photoPath != null && state.photoPath!.isNotEmpty
                    ? (kIsWeb
                        ? Image.network(state.photoPath!, fit: BoxFit.cover)
                        : Image.file(File(state.photoPath!), fit: BoxFit.cover))
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF2ECC71).withOpacity(0.3),
                              const Color(0xFF27AE60).withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Thêm ảnh món ăn',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              // Gradient overlay
              if (state.photoPath != null && state.photoPath!.isNotEmpty)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),
              // Edit button
              if (state.photoPath != null && state.photoPath!.isNotEmpty)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded, color: Color(0xFF2ECC71), size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Đổi ảnh',
                          style: TextStyle(
                            color: Color(0xFF2ECC71),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, RecipeCreateFormState state) {
    return GestureDetector(
      onTap: () => _showTitleDialog(context, state.recipeTitle),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2ECC71).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.recipeTitle.isEmpty ? 'Tên món ăn' : state.recipeTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: state.recipeTitle.isEmpty
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF2D3436),
                    ),
                  ),
                  if (state.recipeTitle.isEmpty)
                    const SizedBox(height: 4),
                  if (state.recipeTitle.isEmpty)
                    Text(
                      'Nhấn để thêm tên',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF9E9E9E).withOpacity(0.8),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2ECC71).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Color(0xFF2ECC71),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCards(RecipeCreateFormState state) {
    return Row(
      children: [
        Expanded(
          child: _buildTimeCard(
            icon: Icons.schedule_rounded,
            label: '${state.prepTime}',
            sublabel: 'Chuẩn bị',
            color: const Color(0xFF3498DB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTimeCard(
            icon: Icons.local_fire_department_rounded,
            label: '${state.cookTime}',
            sublabel: 'Nấu',
            color: const Color(0xFFE74C3C),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTimeCard(
            icon: Icons.timer_rounded,
            label: '${state.totalTime}',
            sublabel: 'Tổng',
            color: const Color(0xFF2ECC71),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeCard({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            '$label phút',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF636E72).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServingsCard(BuildContext context, RecipeCreateFormState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF39C12).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.people_rounded,
              color: Color(0xFFF39C12),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Số người',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                Text(
                  'Khẩu phần ăn',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildCounterButton(
                icon: Icons.remove_rounded,
                onTap: () => context.read<RecipeCreateCubit>().decrementServings(),
              ),
              Container(
                width: 50,
                alignment: Alignment.center,
                child: Text(
                  '${state.servings}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ),
              _buildCounterButton(
                icon: Icons.add_rounded,
                onTap: () => context.read<RecipeCreateCubit>().incrementServings(),
                isPrimary: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isPrimary ? const Color(0xFF2ECC71) : const Color(0xFFEAFAF1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isPrimary ? Colors.white : const Color(0xFF2ECC71),
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> items,
    required String emptyText,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    Color color = const Color(0xFF2ECC71),
    bool isNumbered = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF9E9E9E).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAdd,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Items
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: const Color(0xFFE0E0E0),
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    emptyText,
                    style: const TextStyle(
                      color: Color(0xFF9E9E9E),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey.withOpacity(0.1),
              ),
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key('${title}_$index'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: const Color(0xFFE74C3C),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) => onRemove(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        if (isNumbered)
                          Container(
                            width: 28,
                            height: 28,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            items[index],
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => onRemove(index),
                          child: Icon(
                            Icons.close_rounded,
                            color: const Color(0xFF9E9E9E).withOpacity(0.6),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF39C12).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => context.read<RecipeCreateCubit>().createRecipe(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF39C12),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu_rounded, size: 22),
            SizedBox(width: 10),
            Text(
              'Tạo công thức',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTitleDialog(BuildContext context, String currentTitle) {
    final controller = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit_rounded, color: Color(0xFF2ECC71)),
            SizedBox(width: 10),
            Text('Tên món ăn'),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Nhập tên món ăn',
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<RecipeCreateCubit>().updateRecipeTitle(controller.text);
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(
    BuildContext context,
    String title,
    String hint,
    Function(String) onAdd,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.add_circle_rounded, color: Color(0xFF2ECC71)),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: title.contains('bước') ? 3 : 1,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                onAdd(controller.text);
                Navigator.pop(dialogContext);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Thêm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
