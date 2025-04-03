import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomSegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final List<String> segments;
  final Function(int) onSegmentTapped;

  const CustomSegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.segments,
    required this.onSegmentTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.outline.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(
          segments.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () => onSegmentTapped(index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? AppColors.background
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selectedIndex == index
                      ? [
                          BoxShadow(
                            color: AppColors.outline.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  segments[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: selectedIndex == index
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: selectedIndex == index
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
