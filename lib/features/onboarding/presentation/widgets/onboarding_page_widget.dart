import 'package:falta_app/core/theme/app_theme.dart';
import 'package:falta_app/features/onboarding/data/models/onboarding_page_data.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPageWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 308,
            height: 308,

            alignment: Alignment.center,
            child: Image.asset(data.image),
          ),
          40.hs,
          Text(
            data.title??"",
            textAlign: TextAlign.center,
            style: AppTextStyles.heading,
          ),
          32.hs,
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.description,

          ),
        ],
      ),
    );
  }
}
