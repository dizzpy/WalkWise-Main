import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/colors.dart';

class CustomIconButton extends StatelessWidget {
  final String icon;
  final VoidCallback onPressed;
  final double size;
  final Color? iconColor;
  final Color? borderColor;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 40,
    this.iconColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ?? AppColors.outline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: SvgPicture.asset(
          icon,
          color: iconColor ?? AppColors.primary,
          width: size * 0.5,
          height: size * 0.5,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
