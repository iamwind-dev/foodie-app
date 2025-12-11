import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/shoppinglist_cubit.dart';
import '../cubit/shoppinglist_state.dart';
import '../../../core/widgets/bottom_navigation.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/repositories/favorite_repository.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShoppingListCubit()..loadShoppingList(),
      child: const ShoppingListView(),
    );
  }
}

class ShoppingListView extends StatefulWidget {
  const ShoppingListView({super.key});

  @override
  State<ShoppingListView> createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int _currentNavIndex = 1; // Shopping list tab
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final FavoriteRepository _favoriteRepository = FavoriteRepository();
  List<Map<String, dynamic>> _savedRecipes = [];
  bool _loadingFavorites = true;

  @override
  bool get wantKeepAlive => true;

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
    _loadFavorites();
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      context.read<ShoppingListCubit>().loadShoppingList(),
      _loadFavorites(),
    ]);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == 1) return; // Already on shopping list
    setState(() {
      _currentNavIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  Future<void> _loadFavorites() async {
    final data = await _favoriteRepository.getFavorites();
    if (!mounted) return;
    setState(() {
      _savedRecipes = data;
      _loadingFavorites = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: const Color(0xFFEAFAF1),
      body: Column(
        children: [
          // Header
          _buildHeader(context),
          // Content
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF2ECC71),
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildSavedRecipes(),
                      // Category Tabs
                      
                      // Shopping List
                      
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Bottom Navigation
          // BottomNavigation(
          //   currentIndex: _currentNavIndex,
          //   onTap: _onNavTap,
          //   onShoppingList: () {}, // Already here
          //   onScanRecipe: () => Navigator.pushNamed(context, AppRoutes.aiCaptureRecipe),
          //   onCreateRecipe: () => Navigator.pushNamed(context, AppRoutes.recipeCreate),
          //   onGenerateRecipe: () => Navigator.pushNamed(context, AppRoutes.aiRecipe),
          // ),
        ],
      ),
      floatingActionButton: _buildAddButton(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2ECC71),
            Color(0xFF27AE60),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Back button
              // Material(
              //   color: Colors.transparent,
              //   child: InkWell(
              //     onTap: () => Navigator.pop(context),
              //     borderRadius: BorderRadius.circular(50),
              //     child: Container(
              //       padding: const EdgeInsets.all(8),
              //       decoration: BoxDecoration(
              //         color: Colors.white.withOpacity(0.2),
              //         shape: BoxShape.circle,
              //       ),
              //       child: const Icon(
              //         Icons.arrow_back_rounded,
              //         color: Colors.white,
              //         size: 22,
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(width: 16),
              // Title
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Danh sách công thức',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Quản lý Các công thức đã lưu',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Clear all button
              BlocBuilder<ShoppingListCubit, ShoppingListState>(
                builder: (context, state) {
                  if (state is ShoppingListLoaded && state.items.isNotEmpty) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showClearAllDialog(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 4),
                              Text(
                                'Xóa hết',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedRecipes() {
    if (_loadingFavorites) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: CircularProgressIndicator(color: Color(0xFF2ECC71), strokeWidth: 2),
      );
    }
    if (_savedRecipes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Chưa có công thức đã lưu',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF636E72),
          ),
        ),
      );
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Công thức đã lưu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3436),
              ),
            ),
          ),
          ..._savedRecipes.map((e) {
            final title = (e['title'] ?? '').toString();
            final time = (e['time'] ?? '').toString();
            final calories = (e['calories'] ?? '').toString();
            final data = e['data'] is Map ? Map<String, dynamic>.from(e['data']) : null;
            return GestureDetector(
              onTap: () {
                if (data != null) {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.recipe,
                    arguments: {
                      'recipe': data,
                      'mode': data['mode']?.toString() ?? 'saved',
                      'imageUrl': e['image_url']?.toString(),
                    },
                  );
                } else {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.recipe,
                    arguments: {
                      'recipe': {
                        'name': title,
                        'estimated_time': time,
                        'calories': calories,
                        'mode': 'saved',
                        'image_url': e['image_url']?.toString(),
                      },
                      'mode': 'saved',
                      'imageUrl': e['image_url']?.toString(),
                    },
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.bookmark_border_rounded, color: Color(0xFF2ECC71), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title.isNotEmpty ? title : 'Công thức',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                    ),
                    if (time.isNotEmpty)
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF636E72),
                        ),
                      ),
                    if (calories.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        calories,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF636E72),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<ShoppingListCubit>().changeCategory(value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2ECC71).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF636E72),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Removed unused _buildShoppingList

  Widget _buildProgress(List<ShoppingItem> items) {
    final checkedCount = items.where((item) => item.isChecked).length;
    final progress = items.isEmpty ? 0.0 : checkedCount / items.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
                  strokeWidth: 4,
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2ECC71),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2ECC71).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              color: const Color(0xFF2ECC71).withOpacity(0.5),
              size: 64,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Danh sách trống',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm nguyên liệu cần mua vào đây',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF636E72).withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddItemDialog(context),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Thêm món đầu tiên'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC71),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingItem(BuildContext context, ShoppingItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: const Color(0xFFE74C3C),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) {
        context.read<ShoppingListCubit>().deleteItem(item.id);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Checkbox
            GestureDetector(
              onTap: () {
                context.read<ShoppingListCubit>().toggleItem(item.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: item.isChecked ? const Color(0xFF2ECC71) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: item.isChecked ? const Color(0xFF2ECC71) : const Color(0xFFE0E0E0),
                    width: 2,
                  ),
                ),
                child: item.isChecked
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            // Icon & Name
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getColorForItem(item.name).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIconForItem(item.name),
                color: _getColorForItem(item.name),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  decoration: item.isChecked ? TextDecoration.lineThrough : null,
                  color: item.isChecked ? const Color(0xFF9E9E9E) : const Color(0xFF2D3436),
                ),
              ),
            ),
            // Quantity controls
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildQuantityButton(
                    icon: Icons.remove_rounded,
                    onTap: () => context.read<ShoppingListCubit>().decreaseQuantity(item.id),
                  ),
                  Container(
                    width: 36,
                    alignment: Alignment.center,
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ),
                  _buildQuantityButton(
                    icon: Icons.add_rounded,
                    onTap: () => context.read<ShoppingListCubit>().increaseQuantity(item.id),
                    isPrimary: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isPrimary ? const Color(0xFF2ECC71) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isPrimary ? Colors.white : const Color(0xFF636E72),
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 80),
      child: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: const Color(0xFFF39C12),
        elevation: 8,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Thêm món',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  IconData _getIconForItem(String itemName) {
    final name = itemName.toLowerCase();
    if (name.contains('thịt') || name.contains('steak') || name.contains('meat')) {
      return Icons.set_meal_rounded;
    } else if (name.contains('khoai') || name.contains('potato')) {
      return Icons.breakfast_dining_rounded;
    } else if (name.contains('cà chua') || name.contains('tomato')) {
      return Icons.eco_rounded;
    } else if (name.contains('xúc xích') || name.contains('sausage')) {
      return Icons.lunch_dining_rounded;
    } else if (name.contains('cá') || name.contains('fish') || name.contains('tôm') || name.contains('shrimp')) {
      return Icons.set_meal_rounded;
    } else if (name.contains('rau') || name.contains('vegetable')) {
      return Icons.grass_rounded;
    } else if (name.contains('trứng') || name.contains('egg')) {
      return Icons.egg_rounded;
    } else if (name.contains('sữa') || name.contains('milk')) {
      return Icons.local_drink_rounded;
    }
    return Icons.shopping_basket_rounded;
  }

  Color _getColorForItem(String itemName) {
    final name = itemName.toLowerCase();
    if (name.contains('thịt') || name.contains('steak') || name.contains('meat')) {
      return const Color(0xFFE74C3C);
    } else if (name.contains('cá') || name.contains('fish') || name.contains('tôm')) {
      return const Color(0xFF3498DB);
    } else if (name.contains('rau') || name.contains('vegetable') || name.contains('cà')) {
      return const Color(0xFF2ECC71);
    } else if (name.contains('trứng') || name.contains('egg')) {
      return const Color(0xFFF39C12);
    }
    return const Color(0xFF9B59B6);
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.add_shopping_cart_rounded, color: Color(0xFF2ECC71)),
            SizedBox(width: 10),
            Text('Thêm món mới'),
          ],
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Tên nguyên liệu',
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
            prefixIcon: const Icon(Icons.edit_rounded, color: Color(0xFF9E9E9E)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context.read<ShoppingListCubit>().addItem(
                      nameController.text,
                      'Meat & Seafood',
                    );
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

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFE74C3C)),
            SizedBox(width: 10),
            Text('Xóa tất cả?'),
          ],
        ),
        content: const Text('Bạn có chắc muốn xóa tất cả các món trong danh sách?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF9E9E9E))),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement clear all
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Xóa hết', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
