import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable size input with bottom-sheet picker (for header editing mode)
class SizeInputWidget extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const SizeInputWidget({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.onSurface)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Sélectionner $label',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options[index];
                            final isSelected = option == value;
                            return ListTile(
                              title: Text(
                                option,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? const Color(0xFFEC4899) : null,
                                ),
                              ),
                              onTap: () {
                                onChanged(option);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: context.colors.outlineVariant, width: 0.5)),
              ),
              child: Center(
                child: Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact view-mode size badge
class SizeBadgeWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color? accentColor;

  const SizeBadgeWidget({
    super.key,
    required this.label,
    required this.value,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value.isNotEmpty;
    final color = accentColor ?? context.colors.primary;

    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.colors.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: hasValue 
                ? color.withValues(alpha: 0.15) 
                : context.colors.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasValue 
                  ? color.withValues(alpha: 0.3) 
                  : context.colors.outlineVariant.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            hasValue ? value : '-',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: hasValue 
                  ? color 
                  : context.colors.onSurfaceVariant.withValues(alpha: 0.5),
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}
