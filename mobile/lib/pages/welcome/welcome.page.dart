import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:customer_app/main.dart';
import 'package:customer_app/routes/app_routes.dart';
import 'package:customer_app/theme/theme.dart';

class WelcomePage extends HookConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController(initialPage: 0);
    final currentPage = useState(0);
    final animatedPercent = useState(0.0);

    const int totalPages = 3;

    useEffect(() {
      void listener() {
        if (pageController.hasClients && pageController.page != null) {
          animatedPercent.value = (pageController.page! + 1) / totalPages;
        }
      }

      pageController.addListener(listener);
      animatedPercent.value = (currentPage.value + 1) / totalPages;
      return () => pageController.removeListener(listener);
    }, [pageController]);

    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          currentPage.value = index;
        },
        children: [
          _WelcomeSlide(
            pageController: pageController,
            currentAnimatedPercent: animatedPercent.value,
            imagePath: "assets/images/onboarding_plot.jpg",
            title: "Find Your Dream Plot",
            description:
                "Explore exclusive real estate projects and find the perfect plot for your future home.",
            isLastPage: false,
          ),
          _WelcomeSlide(
            pageController: pageController,
            currentAnimatedPercent: animatedPercent.value,
            imagePath: "assets/images/onboarding_virtual.jpg",
            title: "360° Virtual Tours",
            description:
                "Experience properties from the comfort of your home with immersive 360-degree virtual tours.",
            isLastPage: false,
          ),
          _WelcomeSlide(
            pageController: pageController,
            currentAnimatedPercent: animatedPercent.value,
            imagePath: "assets/images/onboarding_booking.jpg",
            title: "Seamless Booking",
            description:
                "Book plots, track site visits, and manage payments all in one secure platform.",
            isLastPage: true,
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }
}

class _WelcomeSlide extends StatelessWidget {
  final PageController pageController;
  final double currentAnimatedPercent;
  final String imagePath;
  final String title;
  final String description;
  final bool isLastPage;

  const _WelcomeSlide({
    required this.pageController,
    required this.currentAnimatedPercent,
    required this.imagePath,
    required this.title,
    required this.description,
    required this.isLastPage,
  });

  void _onNext(BuildContext context) {
    if (isLastPage) {
      appBox.put('hasSeenWelcome', true);
      context.go(AppRoutes.login);
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children:
                  [
                        const SizedBox(height: 60),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(320, 320),
                                painter: _CirclePainter(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  imagePath,
                                  width: 280,
                                  height: 280,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40.0),
                          child: Text(
                            description,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                          ),
                        ),
                        const SizedBox(height: 180),
                      ]
                      .animate(interval: 50.ms)
                      .fade(duration: 500.ms, curve: Curves.easeOut)
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOut,
                      ),
            ),
          ),
          Positioned(
            top: 60,
            right: 20,
            child: TextButton(
              onPressed: () {
                appBox.put('hasSeenWelcome', true);
                context.go(AppRoutes.login);
              },
              child: Text(
                "Skip",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: CircularPercentIndicator(
                radius: 45.0,
                lineWidth: 4.0,
                percent: currentAnimatedPercent,
                progressColor: AppColors.primary,
                backgroundColor: Colors.grey[200]!,
                circularStrokeCap: CircularStrokeCap.round,
                center: GestureDetector(
                  onTap: () => _onNext(context),
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final Color color;
  _CirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
