import 'package:flutter/material.dart';

class ModernFormField extends StatelessWidget {
  final String label;
  final IconData prefixIcon;
  final Widget child;

  const ModernFormField({
    super.key,
    required this.label,
    required this.prefixIcon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(prefixIcon, color: Colors.white70, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }
}
