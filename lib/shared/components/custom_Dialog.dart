import 'package:flutter/material.dart';
import 'package:mehra_app/shared/components/constants.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final Color iconColor;
  final Color? confirmButtonColor;
  final Color? cancelButtonColor;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Widget? additionalButton;
  final Widget? child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool showIcon;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final TextStyle? confirmTextStyle;
  final TextStyle? cancelTextStyle;
  final Gradient? gradient;
  final double iconSize;
  final EdgeInsetsGeometry buttonPadding;

  const CustomDialog({
    Key? key,
    required this.title,
    required this.content,
    this.confirmText = 'تأكيد',
    this.cancelText = 'إلغاء',
    required this.icon,
    this.iconColor = Colors.white,
    this.confirmButtonColor,
    this.cancelButtonColor,
    required this.onConfirm,
    this.onCancel,
    this.additionalButton,
    this.child,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(24),
    this.showIcon = true,
    this.titleStyle,
    this.contentStyle,
    this.confirmTextStyle,
    this.cancelTextStyle,
    this.gradient,
    this.iconSize = 36,
    this.buttonPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dialogGradient = gradient ?? LinearGradient(
      colors: [
        confirmButtonColor ?? MyColor.blueColor,
        confirmButtonColor ?? MyColor.purpleColor,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      backgroundColor: Colors.white,
      elevation: 4,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: dialogGradient,
                ),
                child: Icon(icon, size: iconSize, color: iconColor),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: titleStyle ?? TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (child != null) 
              child!
            else
              Text(
                content,
                style: contentStyle ?? TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            if (additionalButton != null) ...[
              additionalButton!,
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: onCancel ?? () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: buttonPadding,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: cancelButtonColor ?? Colors.grey),
                    ),
                  ),
                  child: Text(
                    cancelText,
                    style: cancelTextStyle ?? TextStyle(
                      fontSize: 16,
                      color: cancelButtonColor ?? Colors.grey[600],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: dialogGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: (confirmButtonColor ?? MyColor.blueColor).withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: buttonPadding,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      confirmText,
                      style: confirmTextStyle ?? const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    required IconData icon,
    Color iconColor = Colors.white,
    Color? confirmButtonColor,
    Color? cancelButtonColor,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    Widget? additionalButton,
    Widget? child,
    double borderRadius = 24,
    EdgeInsetsGeometry padding = const EdgeInsets.all(24),
    bool showIcon = true,
    TextStyle? titleStyle,
    TextStyle? contentStyle,
    TextStyle? confirmTextStyle,
    TextStyle? cancelTextStyle,
    Gradient? gradient,
    double iconSize = 36,
    EdgeInsetsGeometry buttonPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => CustomDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor,
        confirmButtonColor: confirmButtonColor,
        cancelButtonColor: cancelButtonColor,
        onConfirm: onConfirm,
        onCancel: onCancel,
        additionalButton: additionalButton,
        child: child,
        borderRadius: borderRadius,
        padding: padding,
        showIcon: showIcon,
        titleStyle: titleStyle,
        contentStyle: contentStyle,
        confirmTextStyle: confirmTextStyle,
        cancelTextStyle: cancelTextStyle,
        gradient: gradient,
        iconSize: iconSize,
        buttonPadding: buttonPadding,
      ),
    );
  }
}