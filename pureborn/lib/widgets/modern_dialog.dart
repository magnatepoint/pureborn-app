import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ModernDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final List<Widget> actions;
  final double? maxWidth;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const ModernDialog({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
    this.maxWidth,
    this.showCloseButton = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth ?? 500),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.center,
                colors: [Color(0xFF43e97b), Color(0xFF232323)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(26),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (showCloseButton)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            if (onClose != null) {
                              onClose!();
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: content,
                  ),
                ),
                // Actions
                if (actions.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withAlpha(26),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: actions,
                    ),
                  ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 300),
        );
  }
}

class ModernFormField extends StatelessWidget {
  final String label;
  final Widget child;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;

  const ModernFormField({
    super.key,
    required this.label,
    required this.child,
    this.helperText,
    this.errorText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withAlpha(179),
          ),
        ),
        const SizedBox(height: 8),
        if (prefixIcon != null)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(prefixIcon, color: Colors.white.withAlpha(179)),
                ),
                Expanded(child: child),
              ],
            ),
          )
        else
          child,
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              helperText!,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withAlpha(179),
              ),
            ),
          ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText!,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final IconData? icon;

  const ModernButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isPrimary
                ? Theme.of(context).primaryColor
                : Theme.of(context).cardColor,
        foregroundColor: isPrimary ? Colors.white : Colors.white.withAlpha(179),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
          Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
