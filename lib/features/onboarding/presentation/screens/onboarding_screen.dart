import 'package:falta_app/core/theme/app_colors.dart';
import 'package:falta_app/core/theme/app_theme.dart';
import 'package:falta_app/features/auth/presentation/screens/login_screen.dart';
import 'package:falta_app/features/onboarding/data/models/onboarding_page_data.dart';

import 'package:falta_app/features/onboarding/presentation/widgets/onboarding_page_widget.dart';
import 'package:falta_app/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      image: "assets/images/on_boarding1.png",
      description: 'كورسات وشروحات من أفضل المدرسين لكل المواد الدراسية',
    ),
    OnboardingPageData(
      image: "assets/images/on_boarding2.png",
      description: 'أسئلة حقيقة مع توقيت تلقائي ونتائج فورية وشرح لكل إجابة',
    ),
    OnboardingPageData(
      image: "assets/images/on_boarding3.png",
      description: 'يحلل نتائج امتحانك ويكشف نقاط ضعفك ويلخص المصادر بثواني',
    ),
    OnboardingPageData(
      image: "assets/images/on_boarding4.png",
      title: 'جاهز تبدأ رحلتك نحو التوجيهي؟',
      description: 'سجّل الآن واختر اشتراكك للوصول إلى كل المحتوى والمزايا',
    ),
  ];

  void _goToNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentPage == _pages.length - 1;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // زر التخطي
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: TextButton(
                    onPressed: _navigateToLogin,
                    child: Text(
                      'تخطي',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return OnboardingPageWidget(data: _pages[index]);
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  children: [
                    Visibility(
                      visible: _currentPage != 3,
                      child: Row(
                        children: [



                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_pages.length, (index) {
                              final bool isActive = index == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                                width: isActive ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                          const Spacer(),

                          ElevatedButton(
                            onPressed: _goToNext,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(64, 64),
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Image.asset(
                              "assets/images/next.png",
                              height: 26,
                              width: 26,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Visibility(
                      visible: _currentPage == 3,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_pages.length, (index) {
                              final bool isActive = index == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                                width: isActive ? 24 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                          58.hs,
                          ElevatedButton(
                            onPressed: _goToNext,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: AppColors.primary,
                            ),
                            child: Text(
                              'ابدأ الآن' ,
                              style: AppTextStyles.button.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}