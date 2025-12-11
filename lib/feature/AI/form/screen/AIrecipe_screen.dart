import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/AIrecipe_cubit.dart';
import '../cubit/AIrecipe_state.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../../../../core/constants/app_routes.dart';

class AIRecipeScreen extends StatelessWidget {
  const AIRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AIRecipeCubit()..initialize(),
      child: const AIRecipeView(),
    );
  }
}

class AIRecipeView extends StatefulWidget {
  const AIRecipeView({super.key});

  @override
  State<AIRecipeView> createState() => _AIRecipeViewState();
}

class _AIRecipeViewState extends State<AIRecipeView> with SingleTickerProviderStateMixin {
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _descriptionFocusNode = FocusNode();
  final TextEditingController _ingredientsController = TextEditingController();
  final FocusNode _ingredientsFocusNode = FocusNode();
  int _currentNavIndex = 4; // AI tab
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _descriptionFocusNode.dispose();
    _ingredientsController.dispose();
    _ingredientsFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 4) return; // Already on AI
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
      body: BlocListener<AIRecipeCubit, AIRecipeState>(
        listener: (context, state) {
          if (state is AIRecipeSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.recipe['name']?.toString() ?? 'Đã tạo công thức AI thành công',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF2ECC71),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.recipe,
              arguments: {
                'recipe': state.recipe,
                'mode': state.mode,
              },
            );
          } else if (state is AIRecipeError) {
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
            // Header
            _buildHeader(context),
            
            // Main Content
            Expanded(
              child: BlocBuilder<AIRecipeCubit, AIRecipeState>(
                builder: (context, state) {
                  if (state is AIRecipeGenerating) {
                    return _buildLoadingState();
                  }

                  if (state is! AIRecipeFormState) {
                    return const SizedBox();
                  }

                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // AI Icon Banner
                            _buildAIBanner(),
                            const SizedBox(height: 24),
                            
                            // Heading
                            const Text(
                              'Hãy để AI biến ý tưởng của bạn thành một công thức tuyệt vời!',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2D3436),
                                height: 1.3,
                                letterSpacing: -0.5,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              'Mô tả món ăn bạn muốn, AI sẽ tạo công thức chi tiết cho bạn',
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF636E72).withOpacity(0.8),
                                height: 1.5,
                              ),
                            ),
                            
                            const SizedBox(height: 28),
                            
                            // Ingredients Input Card (optional)
                            _buildIngredientsCard(context, state),
                            
                            const SizedBox(height: 20),
                            
                            // Description Input Card
                            _buildDescriptionCard(context, state),
                            
                            const SizedBox(height: 24),
                            
                            // Tags Section
                            _buildTagsSection(context, state),
                            
                            const SizedBox(height: 24),
                            
                            // Tips Card
                            _buildTipsCard(),
                            
                            const SizedBox(height: 100), // Space for footer
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Footer Button
            _buildFooter(context),
            
            // Bottom Navigation
            // BottomNavigation(
            //   currentIndex: _currentNavIndex,
            //   onTap: _onNavTap,
            //   onShoppingList: () => Navigator.pushNamed(context, AppRoutes.shoppingList),
            //   onScanRecipe: () => Navigator.pushNamed(context, AppRoutes.aiCaptureRecipe),
            //   onCreateRecipe: () => Navigator.pushNamed(context, AppRoutes.recipeCreate),
            //   onGenerateRecipe: () {}, // Already here
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              // Material(
              //   color: Colors.transparent,
              //   child: InkWell(
              //     onTap: () => Navigator.pop(context),
              //     borderRadius: BorderRadius.circular(50),
              //     child: Container(
              //       padding: const EdgeInsets.all(10),
              //       decoration: BoxDecoration(
              //         color: Colors.white.withOpacity(0.8),
              //         shape: BoxShape.circle,
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.black.withOpacity(0.08),
              //             blurRadius: 8,
              //             offset: const Offset(0, 2),
              //           ),
              //         ],
              //       ),
              //       child: const Icon(
              //         Icons.arrow_back_rounded,
              //         color: Color(0xFF2ECC71),
              //         size: 22,
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(width: 120),
              // Title with AI badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF39C12).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'AI Recipe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated AI icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF39C12).withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFF39C12),
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'AI đang tạo công thức...',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng đợi trong giây lát',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: const Color(0xFF636E72).withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: const Color(0xFFEAFAF1),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
              borderRadius: BorderRadius.circular(10),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF39C12).withOpacity(0.15),
            const Color(0xFFE67E22).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF39C12).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF39C12).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFFF39C12),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trình Thuật Sư AI',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3436),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tạo công thức từ mô tả của bạn',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 13,
                    color: Color(0xFF636E72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, AIRecipeFormState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF2ECC71).withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    color: Color(0xFF2ECC71),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Mô tả món ăn',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const Spacer(),
                if (state.description.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.description.length} ký tự',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2ECC71),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // TextField
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _descriptionController,
              focusNode: _descriptionFocusNode,
              maxLines: 5,
              onChanged: (value) {
                context.read<AIRecipeCubit>().updateDescription(value);
              },
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF2D3436),
                height: 1.6,
              ),
              cursorColor: const Color(0xFF2ECC71),
              decoration: InputDecoration(
                hintText: 'Ví dụ: Một món salad mùa hè tươi mát với gà nướng và sốt chanh dây, phù hợp cho bữa trưa nhẹ nhàng...',
                hintStyle: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9E9E9E).withOpacity(0.8),
                  height: 1.6,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsCard(BuildContext context, AIRecipeFormState state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF2ECC71).withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shopping_basket_rounded,
                    color: Color(0xFF2ECC71),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Nguyên liệu (tùy chọn)',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const Spacer(),
                if (state.ingredientsText.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.ingredientsText.split(RegExp(r"[\\n,]")).where((e) => e.trim().isNotEmpty).length} nguyên liệu',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2ECC71),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // TextField
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _ingredientsController,
              focusNode: _ingredientsFocusNode,
              maxLines: 4,
              onChanged: (value) {
                context.read<AIRecipeCubit>().updateIngredientsText(value);
              },
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF2D3436),
                height: 1.6,
              ),
              cursorColor: const Color(0xFF2ECC71),
              decoration: InputDecoration(
                hintText: 'Ví dụ:\n- gà\n- gừng\n- hành lá\n- tỏi\n- nước mắm',
                hintStyle: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF9E9E9E).withOpacity(0.8),
                  height: 1.5,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context, AIRecipeFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.local_offer_rounded,
                color: Color(0xFF9B59B6),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Chọn loại món',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(Tùy chọn)',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13,
                color: const Color(0xFF9E9E9E).withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: context.read<AIRecipeCubit>().availableTags.map((tag) {
            final isSelected = state.selectedTags.contains(tag);
            return GestureDetector(
              onTap: () {
                context.read<AIRecipeCubit>().toggleTag(tag);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? const Color(0xFF2ECC71)
                    : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected 
                      ? const Color(0xFF2ECC71)
                      : const Color(0xFFE0E0E0),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2ECC71).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      tag,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                          ? Colors.white
                          : const Color(0xFF2D3436),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3498DB).withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF3498DB).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline_rounded,
              color: Color(0xFF3498DB),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mẹo hay',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3498DB),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Mô tả càng chi tiết, AI sẽ tạo công thức càng chính xác với mong muốn của bạn!',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 13,
                    color: Color(0xFF636E72),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BlocBuilder<AIRecipeCubit, AIRecipeState>(
        builder: (context, state) {
          final isEnabled = state is AIRecipeFormState &&
              (state.description.trim().isNotEmpty || state.ingredientsText.trim().isNotEmpty);
          
          return Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF2ECC71).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
            ),
            child: ElevatedButton(
              onPressed: isEnabled 
                ? () => context.read<AIRecipeCubit>().generateRecipe()
                : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                disabledBackgroundColor: const Color(0xFFE0E0E0),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: isEnabled ? Colors.white : const Color(0xFF9E9E9E),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Tạo công thức',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isEnabled ? Colors.white : const Color(0xFF9E9E9E),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
