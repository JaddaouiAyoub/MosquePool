import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const AppLogo({super.key, this.size = 40, this.showText = true});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(size * 0.2),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(size * 0.3),
          ),
          child: Icon(Icons.mosque, color: Colors.white, size: size * 0.6),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Text(
            'MosquePool',
            style: TextStyle(
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryBlue,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}
