import 'package:customer_app/pages/auth/forgot_password/forgot_password.page.dart'
    show ForgotPasswordPage;
import 'package:customer_app/pages/auth/login/login.page.dart' show LoginPage;
import 'package:customer_app/pages/auth/register/register.page.dart'
    show RegisterPage;
import 'package:customer_app/pages/emi_tracker/emi_tracker.page.dart'
    show EmiTrackerPage;
import 'package:customer_app/pages/offer_details/offer_details.page.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../pages/profile/profile.page.dart';
import '../pages/profile/kyc_page.dart';
import '../pages/my_properties/my_properties.page.dart';
import '../pages/support/support.page.dart';
// Splash page removed
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
import '../pages/contact/contact.page.dart';
import '../pages/settings/settings.page.dart';
import '../pages/payment/payment.page.dart';
import '../pages/payment_history/payment_history_auth.page.dart';
import '../pages/payment_history/payment_history.page.dart';
import '../pages/legal/legal_content.page.dart';
import '../pages/faq/faq.page.dart';
import '../utils/l10n_extension.dart';

import 'package:flutter/foundation.dart';
import '../providers/auth_provider.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: notifier,
    redirect: (context, state) {
      final user = ref.read(currentUserProvider);
      final isAuth = user != null;
      
      final isGoingToAuth = state.matchedLocation == '/login' || 
                            state.matchedLocation == '/register' || 
                            state.matchedLocation == '/forgot-password';
                            
      final isGoingToPublic = state.matchedLocation == '/terms' || 
                              state.matchedLocation == '/privacy';

      // If not logged in, and not going to an Auth page or Public page, redirect to login
      if (!isAuth && !isGoingToAuth && !isGoingToPublic) {
        return '/login';
      }

      // If logged in and trying to access auth pages, redirect to home
      if (isAuth && isGoingToAuth) {
        return '/home';
      }

      return null;
    },
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'projects',
            builder: (context, state) => const ProjectsPage(),
          ),
          GoRoute(
            path: 'project/:id',
            builder: (context, state) =>
                ProjectDetailsPage(projectId: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'plots',
                builder: (context, state) => PlotAvailabilityPage(
                  projectId: state.pathParameters['id']!,
                ),
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
          GoRoute(
            path: 'offers',
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
            path: 'enquiry',
            builder: (context, state) => EnquiryPage(
              initialProjectId: state.uri.queryParameters['projectId'],
            ),
          ),
          GoRoute(
            path: 'site-visit',
            builder: (context, state) => SiteVisitPage(
              initialProjectId: state.uri.queryParameters['projectId'],
            ),
          ),
          GoRoute(
            path: 'emi-calculator',
            builder: (context, state) => const CalculatorPage(),
          ),
          GoRoute(
            path: 'about',
            builder: (context, state) => const AboutCompanyPage(),
          ),
          GoRoute(
            path: 'contact',
            builder: (context, state) => const ContactUsPage(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: 'payment',
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
            path: 'payment-history-auth',
            builder: (context, state) => const PaymentHistoryAuthPage(),
          ),
          GoRoute(
            path: 'payment-history',
            builder: (context, state) => const PaymentHistoryPage(),
          ),
          GoRoute(
            path: 'terms',
            builder: (context, state) => LegalContentPage(
              documentId: 'terms',
              fallbackTitle: context.l10n.termsAndConditions,
            ),
          ),
          GoRoute(
            path: 'privacy',
            builder: (context, state) => LegalContentPage(
              documentId: 'privacy',
              fallbackTitle: context.l10n.privacyPolicy,
            ),
          ),
          GoRoute(path: 'faq', builder: (context, state) => const FaqPage()),
        ],
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/kyc',
        builder: (context, state) => const KycPage(),
      ),
      GoRoute(
        path: '/my-properties',
        builder: (context, state) => const MyPropertiesPage(),
      ),
      GoRoute(
        path: '/my-properties/:plotId/emi-tracker',
        builder: (context, state) =>
            EmiTrackerPage(plotId: state.pathParameters['plotId']!),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportPage(),
      ),
    ],
  );
});
