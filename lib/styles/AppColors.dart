import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {

  static const Color primaryColor = const Color(0xFF7ac8ee);
  static const Color secondaryColor = const Color(0xFF9489f4);
  //static const Color bgColor = const Color(0xff1f252d);
  static const Color bgColor = const Color(0xff3f4a57);
  static const Color secondaryBgColor = const Color(0xff4b586a);


  static const primaryGradient = const LinearGradient(
    colors: const [primaryColor, secondaryColor],
    stops: const [0.0, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
