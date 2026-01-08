import 'package:flutter/material.dart';
import '../models/keyboard_theme.dart';

class KeyButton extends StatefulWidget {
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
  State<KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<KeyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isSpecial
        ? widget.theme.specialKeyColor
        : widget.theme.keyColor;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(opacity: _opacityAnimation.value, child: child),
          );
        },
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(widget.theme.keyRadius),
          elevation: widget.theme.keyElevation,
          shadowColor: Colors.black38,
          child: InkWell(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onLongPress: widget.onLongPress,
            borderRadius: BorderRadius.circular(widget.theme.keyRadius),
            // Enhanced ripple colors
            splashColor: widget.theme.keyPressedColor.withOpacity(0.5),
            highlightColor: widget.theme.keyPressedColor.withOpacity(0.3),
            splashFactory: InkRipple.splashFactory,
            radius: widget.width * 0.6, // Control ripple size
            child: Ink(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.theme.keyRadius),
              ),
              child: Center(
                child: widget.icon != null
                    ? Icon(widget.icon, size: 20, color: widget.theme.textColor)
                    : Text(
                        widget.label,
                        style: TextStyle(
                          fontSize: widget.fontSize ?? 18,
                          color: widget.theme.textColor,
                          fontFamily: widget.fontFamily,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
