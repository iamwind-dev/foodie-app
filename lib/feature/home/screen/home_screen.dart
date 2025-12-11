import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import '../../../core/widgets/widgets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/navigation_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/repositories/external_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit()..loadHomeData(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  int _currentNavIndex = NavigationIndex.home;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final _externalRepo = ExternalRepository();

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  Future<void> _openExternalRecipe(String id) async {
    try {
      _showLoadingDialog();
      final detail = await _externalRepo.getDishDetail(id);
      Navigator.pop(context); // close loading

      final mapped = _mapExternalDetailToRecipe(detail);
      Navigator.pushNamed(
        context,
        AppRoutes.recipe,
        arguments: {
          'recipe': mapped,
          'mode': 'vendor',
          'imageUrl': detail['hinh_anh']?.toString(),
        },
      );
    } catch (e) {
      Navigator.pop(context, null); // ensure dialog closed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không tải được món ăn: $e')),
      );
    }
  }

  Map<String, dynamic> _mapExternalDetailToRecipe(Map<String, dynamic> d) {
    final ingredients = <Map<String, String>>[];
    if (d['nguyen_lieu'] is List) {
      for (final item in d['nguyen_lieu']) {
        if (item is Map) {
          final name = item['ten_nguyen_lieu']?.toString() ?? '';
          final qtyRaw = item['dinh_luong']?.toString() ?? '';
          final unit = item['don_vi_goc']?.toString() ?? '';
          final qty = unit.isNotEmpty ? '$qtyRaw $unit' : qtyRaw;
          if (name.isNotEmpty) {
            ingredients.add({'name': name, 'quantity': qty});
          }
        }
      }
    }

    final instructions = <String>[];
    final stepRaw = d['cach_thuc_hien']?.toString() ?? '';
    if (stepRaw.isNotEmpty) {
      instructions.addAll(stepRaw.split(RegExp(r'\r?\n')).where((s) => s.trim().isNotEmpty).map((s) => s.trim()));
    }

    final tools = <String>[];
    if (d['danh_muc'] is List) {
      for (final c in d['danh_muc']) {
        if (c is Map) {
          final t = c['ten_danh_muc_mon_an']?.toString();
          if (t != null && t.isNotEmpty) tools.add(t);
        }
      }
    }

    final time = d['khoang_thoi_gian']?.toString() ?? 'N/A';
    final calories = d['calories']?.toString() ??
        d['calories_tong_theo_khau_phan']?.toString() ??
        d['calories_moi_khau_phan']?.toString();
    final servings = d['khau_phan_hien_tai'] ?? d['khau_phan_tieu_chuan'] ?? 1;

    return {
      'name': d['ten_mon_an']?.toString() ?? 'Món ăn',
      'ingredients': ingredients,
      'tools': tools,
      'instructions': instructions,
      'estimated_time': time,
      'calories': calories,
      'servings': servings,
      'mode': 'vendor',
      'image_url': d['hinh_anh']?.toString(),
    };
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top bar with gradient
          _buildTopBar(),
          // Content
          Expanded(
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const AppLoadingWidget(message: 'Đang tải...');
                }
                
                if (state is HomeError) {
                  return AppErrorWidget(
                    title: 'Có lỗi xảy ra',
                    message: state.message,
                  );
                }
                
                if (state is HomeLoaded) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      key: const PageStorageKey('home_scroll'),
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // Search bar
                          AppSearchField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            hintText: 'Tìm kiếm công thức...',
                            onFilterTap: () {
                              // Filter action
                            },
                          ),
                          const SizedBox(height: 24),
                          // Generate recipe button
                          _buildGenerateRecipeButton(),
                          const SizedBox(height: 24),
                          // Recipe examples
                          _buildRecipeExamples(state.recipes),
                          const SizedBox(height: 28),
                          // Suggestions section
                          _buildSuggestionsSection(state.suggestions),
                          const SizedBox(height: 28),
                          // Countries section
                          _buildCountriesSection(state.countries),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  );
                }
                
                return const SizedBox();
              },
            ),
          ),
          // Bottom navigation
          // BottomNavigation(
          //   currentIndex: _currentNavIndex,
          //   onTap: _onNavTap,
          //   onShoppingList: () {
          //     Navigator.pushNamed(context, AppRoutes.shoppingList);
          //   },
          //   onScanRecipe: () {
          //     Navigator.pushNamed(context, AppRoutes.aiCaptureRecipe);
          //   },
          //   onCreateRecipe: () {
          //     Navigator.pushNamed(context, AppRoutes.recipeCreate);
          //   },
          //   onGenerateRecipe: () {
          //     Navigator.pushNamed(context, AppRoutes.aiRecipe);
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return SoftGradientHeader(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Row(
          children: [
            // Logo with subtle shadow
            Container(
              padding: const EdgeInsets.all(4),
              
              child: Image.asset(
                'assets/img/logo1.png',
                width: 70,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
            const Spacer(),
            // Greeting text
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Xin chào!',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Hôm nay nấu gì?',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Settings button
            AppIconButton(
              icon: Icons.settings_rounded,
              iconColor: AppColors.primary,
              backgroundColor: Colors.white.withOpacity(0.8),
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.setting);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateRecipeButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.aiRecipe);
      },
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  'assets/img/home_generate_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(0xFF6C4200).withOpacity(0.7),
                        const Color(0xFF6C4200).withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tạo công thức',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            color: Color(0x60000000),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Từ nguyên liệu có sẵn',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Positioned(
                right: 20,
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeExamples(List<Recipe> recipes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SimpleSectionHeader(
          icon: Icons.restaurant_menu_rounded,
          title: 'Công thức nổi bật',
          iconColor: AppColors.accent,
          onViewAllTap: () {},
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Padding(
                padding: EdgeInsets.only(right: index < recipes.length - 1 ? 16 : 0),
                child: RecipeCard(
                  imageUrl: recipe.imageUrl,
                  name: recipe.name,
                  width: 240,
                  height: 160,
                  onTap: () => _openExternalRecipe(recipe.id),
                  onFavoriteTap: () {
                    // Toggle favorite
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsSection(List<Recipe> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SimpleSectionHeader(
          icon: Icons.lightbulb_outline_rounded,
          title: 'Gợi ý cho bạn',
          subtitle: 'Dựa trên món Phở bạn đã xem',
          iconColor: AppColors.accent,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final suggestion = suggestions[index];
              return Padding(
                padding: EdgeInsets.only(right: index < suggestions.length - 1 ? 16 : 0),
                child: RecipeCard(
                  imageUrl: suggestion.imageUrl,
                  name: suggestion.name,
                  width: 150,
                  height: 180,
                  onTap: () => _openExternalRecipe(suggestion.id),
                  onFavoriteTap: () {},
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCountriesSection(List<Country> countries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SimpleSectionHeader(
          icon: Icons.public_rounded,
          title: 'Ẩm thực các nước',
          iconColor: AppColors.primary,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: countries.length,
            itemBuilder: (context, index) {
              final country = countries[index];
              return Padding(
                padding: EdgeInsets.only(right: index < countries.length - 1 ? 16 : 0),
                child: _buildCountryCard(country),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCountryCard(Country country) {
    return Container(
      width: 150,
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Image
            Positioned.fill(
              child: Image.asset(
                country.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
            // Country name
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          color: Color(0x80000000),
                          offset: Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '10+ món',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
