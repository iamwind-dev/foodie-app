import 'package:flutter/material.dart';

/// Reusable bottom navigation bar widget with modern design
/// 
/// Features:
/// - Floating design with rounded corners
/// - Animated icons with scale effect
/// - Gradient background
/// - Shadow for depth
/// 
/// Usage example:
/// ```dart
/// BottomNavigation(
///   currentIndex: _currentNavIndex,
///   onTap: (index) {
///     setState(() {
///       _currentNavIndex = index;
///     });
///   },
///   onCreateRecipe: () => Navigator.pushNamed(context, '/create'),
///   onGenerateRecipe: () => Navigator.pushNamed(context, '/generate'),
///   onScanRecipe: () => Navigator.pushNamed(context, '/scan'),
///   onShoppingList: () => Navigator.pushNamed(context, '/shopping'),
/// )
/// ```
class BottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onCreateRecipe;
  final VoidCallback? onGenerateRecipe;
  final VoidCallback? onScanRecipe;
  final VoidCallback? onShoppingList;
  final bool isFixed; // if true, only onTap is used (no Navigator push)

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCreateRecipe,
    this.onGenerateRecipe,
    this.onScanRecipe,
    this.onShoppingList,
    this.isFixed = false,
  });

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      5,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );
    _scaleAnimations = _controllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 0.85).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTapDown(int index) {
    _controllers[index].forward();
  }

  void _onTapUp(int index) {
    _controllers[index].reverse();
  }

  void _onTapCancel(int index) {
    _controllers[index].reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2ECC71),
            Color(0xFF27AE60),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home button
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                index: 0,
                isSelected: widget.currentIndex == 0,
                onTap: () => widget.onTap(0),
              ),
              
              // Shopping List button
              _buildNavItem(
                icon: Icons.favorite,
                label: 'Công thức',
                index: 1,
                isSelected: widget.currentIndex == 1,
                onTap: () {
                  widget.onTap(1);
                  if (!widget.isFixed) widget.onShoppingList?.call();
                },
              ),
              
              // Scan a recipe button (center - special)
              _buildCenterButton(
                icon: Icons.camera_alt_rounded,
                index: 2,
                onTap: () {
                  if (!widget.isFixed) {
                    widget.onScanRecipe?.call();
                  } else {
                    widget.onTap(2);
                  }
                },
              ),
              
              // Create your own recipe button
              _buildNavItem(
                icon: Icons.edit_note_rounded,
                label: 'Tạo',
                index: 3,
                isSelected: widget.currentIndex == 3,
                onTap: () {
                  widget.onTap(3);
                  if (!widget.isFixed) widget.onCreateRecipe?.call();
                },
              ),
              
              // Generate a recipe button
              _buildNavItem(
                icon: Icons.auto_awesome_rounded,
                label: 'AI',
                index: 4,
                isSelected: widget.currentIndex == 4,
                onTap: () {
                  widget.onTap(4);
                  if (!widget.isFixed) widget.onGenerateRecipe?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(index),
      onTapUp: (_) {
        _onTapUp(index);
        onTap();
      },
      onTapCancel: () => _onTapCancel(index),
      child: ScaleTransition(
        scale: _scaleAnimations[index],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 14 : 10,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.white 
                : Colors.white.withOpacity(0.0),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected 
                    ? const Color(0xFF2ECC71) 
                    : Colors.white.withOpacity(0.9),
                size: isSelected ? 24 : 26,
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF2ECC71),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton({
    required IconData icon,
    required int index,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTapDown: (_) => _onTapDown(index),
      onTapUp: (_) {
        _onTapUp(index);
        onTap();
      },
      onTapCancel: () => _onTapCancel(index),
      child: ScaleTransition(
        scale: _scaleAnimations[index],
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF39C12),
                Color(0xFFE67E22),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF39C12).withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
