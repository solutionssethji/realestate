import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../pages/splash/splash.page.dart';
import '../pages/home/home.page.dart';
import '../pages/projects/projects.page.dart';
import '../pages/project_details/project_details.page.dart';
import '../pages/plot_availability/plot_availability.page.dart';
import '../pages/plot_details/plot_details.page.dart';
import '../pages/offers/offers.page.dart';
import '../pages/offers/offer_details.page.dart';
import '../pages/enquiry/enquiry.page.dart';
import '../pages/site_visit/site_visit.page.dart';
import '../pages/emi_calculator/emi_calculator.page.dart';
import '../pages/about/about.page.dart';
import '../pages/contact/contact.page.dart';
import '../pages/settings/settings.page.dart';
import '../pages/payment/payment.page.dart';
import '../pages/payment_history/payment_history_auth.page.dart';
import '../pages/payment_history/payment_history.page.dart';
import '../pages/legal/legal_content.page.dart';
import '../pages/faq/faq.page.dart';
import '../utils/l10n_extension.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashPage()),
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
            builder: (context, state) => const EmiCalculatorPage(),
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
    ],
  );
});
