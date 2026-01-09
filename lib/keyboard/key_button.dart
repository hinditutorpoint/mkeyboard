import 'package:flutter/material.dart';
import '../models/keyboard_theme.dart';

class KeyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double width;
  final double height;
  final KeyboardTheme theme;
  final bool isSpecial;
  final IconData? icon;
  final String? fontFamily;
  final double? fontSize;

  const KeyButton({
    super.key,
    required this.label,
    this.onTap,
    this.onLongPress,
    required this.width,
    required this.height,
    required this.theme,
    this.isSpecial = false,
    this.icon,
    this.fontFamily,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSpecial ? theme.specialKeyColor : theme.keyColor;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(theme.keyRadius),
      elevation: theme.keyElevation,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(theme.keyRadius),
        splashColor: theme.keyPressedColor.withValues(alpha: 0.4),
        highlightColor: theme.keyPressedColor.withValues(alpha: 0.2),
        child: SizedBox(
          width: width,
          height: height,
          child: Center(
            child: icon != null
                ? Icon(icon, size: 20, color: theme.textColor)
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: fontSize ?? 18,
                      color: theme.textColor,
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ),
      ),
    );
  }
}
