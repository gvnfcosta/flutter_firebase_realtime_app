import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';
import '../../../config/app_data.dart';

// ===================== TÍTULO DO APP =====================

/// Apresenta o Título do App nas telas Splash Screen e SignIn Screen
Widget appTitle(Size size) {
  double fontSize = size.height * 0.04;
  return Visibility(
    visible: true,

    child: Column(
      children: [
        Text(
          programName,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Arbotek',
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.backGroundColor,
            height: 1.2,
          ),
        ),
      ],
    ),
  );
}
