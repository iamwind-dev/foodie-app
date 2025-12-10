import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Counter widget with increment/decrement buttons
class CounterWidget extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int? minValue;
  final int? maxValue;
  final double buttonSize;
  final double fontSize;

  const CounterWidget({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.minValue,
    this.maxValue,
    this.buttonSize = 44,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrement = minValue == null || value > minValue!;
    final canIncrement = maxValue == null || value < maxValue!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove_rounded,
            onTap: canDecrement ? onDecrement : null,
            isPrimary: false,
          ),
          Container(
            width: 50,
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          _buildButton(
            icon: Icons.add_rounded,
            onTap: canIncrement ? onIncrement : null,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isPrimary,
  }) {
    final isEnabled = onTap != null;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            gradient: isPrimary && isEnabled
                ? AppColors.primaryGradient
                : null,
            color: !isPrimary || !isEnabled
                ? (isEnabled ? null : AppColors.divider.withOpacity(0.3))
                : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: isPrimary && isEnabled
                ? Colors.white
                : (isEnabled ? AppColors.textSecondary : AppColors.textHint),
            size: 22,
          ),
        ),
      ),
    );
  }
}

/// Servings counter with label
class ServingsCounter extends StatelessWidget {
  final int servings;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final String label;
  final IconData icon;

  const ServingsCounter({
    super.key,
    required this.servings,
    required this.onIncrement,
    required this.onDecrement,
    this.label = 'Số người ăn',
    this.icon = Icons.people_alt_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primaryDark.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          CounterWidget(
            value: servings,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
            minValue: 1,
          ),
        ],
      ),
    );
  }
}

/// Simple quantity counter (compact version)
class QuantityCounter extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final Color? primaryColor;

  const QuantityCounter({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = primaryColor ?? AppColors.primary;
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSmallButton(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
            color: color,
            isPrimary: false,
          ),
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _buildSmallButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
            color: color,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required bool isPrimary,
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
            color: isPrimary ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isPrimary ? Colors.white : AppColors.textSecondary,
            size: 18,
          ),
        ),
      ),
    );
  }
}

