import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_text_styles.dart';

/// Custom button with elderly-friendly press feedback animation.
/// Provides subtle scale animation (0.95) on press for clear tactile feedback.
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.icon,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = widget.height ?? AppDimensions.buttonHeight;
    final buttonWidth = widget.width ?? double.infinity;

    // Wrap button with scale animation for elderly-friendly press feedback
    return GestureDetector(
      onTapDown: widget.onPressed != null && !widget.isLoading
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onPressed != null && !widget.isLoading
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel: widget.onPressed != null && !widget.isLoading
          ? () => setState(() => _isPressed = false)
          : null,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: widget.isOutlined
            ? _buildOutlinedButton(buttonWidth, buttonHeight)
            : _buildElevatedButton(buttonWidth, buttonHeight),
      ),
    );
  }

  Widget _buildOutlinedButton(double buttonWidth, double buttonHeight) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: widget.textColor ?? AppColors.primaryTurquoise,
          side: BorderSide(
            color: widget.textColor ?? AppColors.primaryTurquoise,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing24,
          ),
        ),
        child: _buildButtonChild(),
      ),
    );
  }

  Widget _buildElevatedButton(double buttonWidth, double buttonHeight) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? AppColors.primaryTurquoise,
          foregroundColor: widget.textColor ?? AppColors.white,
          disabledBackgroundColor: AppColors.textHint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacing24,
          ),
          elevation: 2,
        ),
        child: _buildButtonChild(),
      ),
    );
  }

  Widget _buildButtonChild() {
    if (widget.isLoading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.isOutlined ? AppColors.primaryTurquoise : AppColors.white,
          ),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.icon!,
          const SizedBox(width: AppDimensions.spacing12),
          Text(
            widget.text,
            style: AppTextStyles.button.copyWith(
              color: widget.isOutlined
                  ? (widget.textColor ?? AppColors.primaryTurquoise)
                  : (widget.textColor ?? AppColors.white),
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: AppTextStyles.button.copyWith(
        color: widget.isOutlined
            ? (widget.textColor ?? AppColors.primaryTurquoise)
            : (widget.textColor ?? AppColors.white),
      ),
    );
  }
}
