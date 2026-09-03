import 'package:customer_app/pages/auth/forgot_password/forgot_password.page.dart'
    show ForgotPasswordPage;
import 'package:customer_app/pages/auth/login/login.page.dart' show LoginPage;
import 'package:customer_app/pages/auth/register/register.page.dart'
    show RegisterPage;
import '../pages/booking_details/booking_details.page.dart'
    show BookingDetailsPage;
import 'package:customer_app/pages/offer_details/offer_details.page.dart';
import 'package:customer_app/pages/referral/referral.page.dart';
import '../pages/referred_users/referred_users.page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../main.dart';
import '../pages/profile/profile.page.dart';
import '../pages/profile/edit_profile/edit_profile.page.dart';
import '../pages/auth/change_password/change_password.page.dart';
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
import '../pages/payment/payment.page.dart';
import '../pages/payment_history_auth/payment_history_auth.page.dart';
import '../pages/payment_history/payment_history.page.dart';
import '../pages/my_enquiries/my_enquiries.page.dart';
import '../pages/my_site_visits/my_site_visits.page.dart';
import '../widgets/bottom_nav_bar/bottom_nav_bar.widget.dart';
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
    initialLocation: AppRoutes.home,
    refreshListenable: notifier,
    redirect: (context, state) {
      final isAuth = appBox.get('authToken') != null;

      final isGoingToAuth =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword;

      const isGoingToPublic = false;

      if (!isAuth && !isGoingToAuth && !isGoingToPublic) {
        return AppRoutes.login;
      }

      if (isAuth && isGoingToAuth) {
        return AppRoutes.home;
      }

      return null;
    },
    debugLogDiagnostics: false,
    routes: [
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
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
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
      GoRoute(
        path: AppRoutes.payment,
        builder: (context, state) {
          final params = state.uri.queryParameters;
          final amount = double.tryParse(params['amount'] ?? '0') ?? 0;
          final refId = params['refId'] ?? '';
          final desc = params['desc'] ?? '';
          return PaymentPage(
            amount: amount,
            referenceId: refId,
            description: desc,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.paymentHistoryAuth,
        builder: (context, state) => const PaymentHistoryAuthPage(),
      ),
      GoRoute(
        path: AppRoutes.paymentHistory,
        builder: (context, state) => const PaymentHistoryPage(),
      ),

      // Project Details Routes
      GoRoute(
        path: AppRoutes.projectDetailsBase,
        builder: (context, state) =>
            ProjectDetailsPage(projectId: state.pathParameters['id']!),
        routes: [
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
        path: '/booking-details/:plotId',
        builder: (context, state) =>
            BookingDetailsPage(plotId: state.pathParameters['plotId']!),
      ),

      // Profile Routes
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordPage(),
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
