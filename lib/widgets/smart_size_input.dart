import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/sizing_constants.dart';

class SmartSizeInput extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool isShoe;

  const SmartSizeInput({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
    this.isShoe = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 8),
        if (isShoe)
          _buildShoeSelector(context, isDark)
        else
          _buildClothingSelector(context, isDark),
      ],
    );
  }

  Widget _buildShoeSelector(BuildContext context, bool isDark) {
    final sizes = SizingConstants.shoeSizes;
    
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sizes.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final size = sizes[index];
          final isSelected = size == value;
          
          return GestureDetector(
            onTap: () => onChanged(size),
            child: Container(
              width: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 48,
              decoration: AppTheme.selectionDecoration(isSelected, context),
              child: Center(
                child: Text(
                  size,
                  style: AppTheme.selectionTextStyle(isSelected, context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClothingSelector(BuildContext context, bool isDark) {
    const sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
    
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sizes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final size = sizes[index];
          final isSelected = size == value;
          
          return GestureDetector(
            onTap: () => onChanged(size),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: AppTheme.selectionDecoration(isSelected, context),
              child: Text(
                size,
                style: AppTheme.selectionTextStyle(isSelected, context),
              ),
            ),
          );
        },
      ),
    );
  }
}
