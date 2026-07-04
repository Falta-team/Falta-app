import 'package:flutter/material.dart';

/// نموذج بيانات شاشة الترحيب الواحدة
class OnboardingPageData {
  final String image;
  final String? title;
  final String description;

  const OnboardingPageData(
      {
    required this.image,
    required this.description,
        this.title,

  }

  );
}
