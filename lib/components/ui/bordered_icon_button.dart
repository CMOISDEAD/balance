import 'package:flutter/material.dart';

class BorderedIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color borderColor;
  final Color iconColor;
  final Color backgroundColor;

  const BorderedIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 40,
    this.borderColor = Colors.grey,
    this.iconColor = Colors.black,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, size: size * 0.5),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: size / 2,
      ),
    );
  }
}
