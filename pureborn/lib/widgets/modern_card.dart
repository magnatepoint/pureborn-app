import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? leading;
  final Widget? trailing;
  final String? title;
  final String? subtitle;
  final Color? accentColor;
  final VoidCallback? onTap;
  final bool isExpanded;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.leading,
    this.trailing,
    this.title,
    this.subtitle,
    this.accentColor,
    this.onTap,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          margin:
              margin ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.darkCard, AppTheme.darkCard.withAlpha(242)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.12 * 255).round()),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Accent bar
                  if (accentColor != null)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 6,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: padding ?? const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null ||
                            leading != null ||
                            trailing != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (leading != null) ...[
                                leading!,
                                const SizedBox(width: 12),
                              ],
                              if (title != null)
                                Expanded(
                                  child: Text(
                                    title!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              if (trailing != null) ...[
                                const SizedBox(width: 12),
                                trailing!,
                              ],
                            ],
                          ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withAlpha(
                                (0.7 * 255).round(),
                              ),
                            ),
                          ),
                        ],
                        if (title != null || subtitle != null)
                          const SizedBox(height: 12),
                        AnimatedCrossFade(
                          firstChild: child,
                          secondChild: const SizedBox.shrink(),
                          crossFadeState:
                              isExpanded
                                  ? CrossFadeState.showFirst
                                  : CrossFadeState.showSecond,
                          duration: const Duration(milliseconds: 300),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideY(
          begin: 0.1,
          end: 0,
          duration: const Duration(milliseconds: 300),
        );
  }
}
