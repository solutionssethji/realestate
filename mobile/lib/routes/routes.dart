import 'package:customer_app/pages/auth/otp/otp.page.dart' show OtpPage;
import 'package:customer_app/pages/auth/login/login.page.dart' show LoginPage;
import 'package:customer_app/pages/auth/register/register.page.dart'
    show RegisterPage;
import '../pages/booking_details/booking_details.page.dart'
    show BookingDetailsPage;
import 'package:customer_app/pages/offer_details/offer_details.page.dart';
import 'package:customer_app/pages/referral/referral.page.dart';
import '../pages/referred_users/referred_users.page.dart';
import '../pages/notifications/notifications.page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../main.dart';
import '../pages/profile/profile.page.dart';
import '../pages/profile/edit_profile/edit_profile.page.dart';
import '../pages/kyc/kyc.page.dart';
import '../pages/my_properties/my_properties.page.dart';
import '../pages/support/support.page.dart';
import '../pages/home/home.page.dart';
import '../pages/projects/projects.page.dart';
import '../pages/project_details/project_details.page.dart';
import '../pages/plot_availability/plot_availability.page.dart';
import '../pages/plot_details/plot_details.page.dart';
import '../pages/offers/offers.page.dart';
import '../pages/enquiry/enquiry.page.dart';
import '../pages/site_visit/site_visit.page.dart';
import '../pages/calculator/calculator.page.dart';
import '../pages/about/about.page.dart';
import '../pages/my_enquiries/my_enquiries.page.dart';
import '../pages/my_site_visits/my_site_visits.page.dart';
import '../widgets/bottom_nav_bar/bottom_nav_bar.widget.dart';
import '../pages/splash/splash.page.dart';
import '../pages/virtual_tour/virtual_tour.page.dart';
import '../pages/welcome/welcome.page.dart';
import '../pages/language_selection/language_selection.page.dart';
import 'app_routes.dart';

import '../providers/auth_provider.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(currentUserProvider, (_, _) => notifyListeners());
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: notifier,
    redirect: (context, state) {
      // Allow Splash Screen to load and handle its own navigation
      if (state.matchedLocation == AppRoutes.splash) {
        return null;
      }

      final isAuth = appBox.get('authToken') != null;
      final hasSelectedLanguage =
          appBox.get('hasSelectedLanguage', defaultValue: false) as bool;
      final hasSeenWelcome =
          appBox.get('hasSeenWelcome', defaultValue: false) as bool;

      if (!hasSelectedLanguage &&
          state.matchedLocation != AppRoutes.languageSelection) {
        return AppRoutes.languageSelection;
      }

      if (hasSelectedLanguage &&
          !hasSeenWelcome &&
          state.matchedLocation != AppRoutes.welcome &&
          state.matchedLocation != AppRoutes.languageSelection) {
        return AppRoutes.welcome;
      }

      final isGoingToAuth =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.otp;

      const isGoingToPublic = false;

      if (!isAuth &&
          !isGoingToAuth &&
          !isGoingToPublic &&
          state.matchedLocation != AppRoutes.welcome &&
          state.matchedLocation != AppRoutes.languageSelection) {
        return AppRoutes.login;
      }

      if (isAuth && isGoingToAuth) {
        return AppRoutes.home;
      }

      return null;
    },
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.languageSelection,
        builder: (context, state) => const LanguageSelectionPage(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomePage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BottomNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // Branch 1: Projects
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.projects,
                builder: (context, state) => const ProjectsPage(),
              ),
            ],
          ),
          // Branch 2: Booked (My Properties)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.myProperties,
                builder: (context, state) => const MyPropertiesPage(),
              ),
            ],
          ),
          // Branch 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return RegisterPage(
            phoneNumber: extras?['phoneNumber'] as String?,
            countryCode: extras?['countryCode'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          final verificationId = extras?['verificationId'] as String? ?? '';
          final phoneNumber = extras?['phoneNumber'] as String? ?? '';
          final completeNumber = extras?['completeNumber'] as String? ?? '';
          final countryCode = extras?['countryCode'] as String? ?? '';
          return OtpPage(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
            completeNumber: completeNumber,
            countryCode: countryCode,
          );
        },
      ),

      // Other Top-Level Routes (these hide the bottom nav bar naturally)
      GoRoute(
        path: AppRoutes.offers,
        builder: (context, state) => const OffersPage(),
        routes: [
          GoRoute(
            path: ':offerId',
            builder: (context, state) =>
                OfferDetailsPage(offerId: state.pathParameters['offerId']!),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.enquiry,
        builder: (context, state) => EnquiryPage(
          initialProjectId: state.uri.queryParameters['projectId'],
          initialPlotId: state.uri.queryParameters['plotId'],
        ),
      ),
      GoRoute(
        path: AppRoutes.siteVisit,
        builder: (context, state) => SiteVisitPage(
          initialProjectId: state.uri.queryParameters['projectId'],
        ),
      ),
      GoRoute(
        path: AppRoutes.emiCalculator,
        builder: (context, state) => const CalculatorPage(),
      ),
      GoRoute(
        path: AppRoutes.about,
        builder: (context, state) => const AboutCompanyPage(),
      ),
      GoRoute(
        path: AppRoutes.myEnquiries,
        builder: (context, state) => const MyEnquiriesPage(),
      ),
      GoRoute(
        path: AppRoutes.mySiteVisits,
        builder: (context, state) => const MySiteVisitsPage(),
      ),

      // Project Details Routes
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: AppRoutes.projectDetailsBase,
        builder: (context, state) =>
            ProjectDetailsPage(projectId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: '360-tour',
            builder: (context, state) {
              final url = state.uri.queryParameters['url'] ?? '';
              return VirtualTourPage(url: url);
            },
          ),
          GoRoute(
            path: 'plots',
            builder: (context, state) =>
                PlotAvailabilityPage(projectId: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: ':plotId',
                builder: (context, state) => PlotDetailsPage(
                  projectId: state.pathParameters['id']!,
                  plotId: state.pathParameters['plotId']!,
                ),
              ),
            ],
          ),
        ],
      ),

      // My Properties Routes
      GoRoute(
        path: '/booking-details/:id',
        builder: (context, state) =>
            BookingDetailsPage(id: state.pathParameters['id']!),
      ),

      // Profile Routes
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.kyc,
        builder: (context, state) => const KycPage(),
      ),
      GoRoute(
        path: AppRoutes.support,
        builder: (context, state) => const SupportPage(),
      ),
      GoRoute(
        path: AppRoutes.referral,
        builder: (context, state) => const ReferralPage(),
      ),
      GoRoute(
        path: AppRoutes.referredUsers,
        builder: (context, state) => const ReferredUsersPage(),
      ),
    ],
  );
});
