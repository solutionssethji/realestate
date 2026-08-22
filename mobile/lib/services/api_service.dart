import 'dart:convert';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/project.dart';
import '../models/plot.dart';
import '../models/plot_status.dart';
import '../models/offer.dart';
import '../utils/bilingual_helper.dart';

/// Central service for all Firebase data operations.
/// UI → Logic → ApiService → Firebase (Firestore / Functions / Storage)
///
/// Never call Firestore directly from a widget or page.
class ApiService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // ─── Test overrides (used ONLY in tests, never in production) ───────────────
  static Future<Map<String, dynamic>> Function(Map<String, dynamic> data)?
  mockSubmitPayment;
  static Future<List<Plot>> Function(String projectId)? mockGetPlots;

  // ─── Settings ───────────────────────────────────────────────────────────────

  static Future<Map<String, String>> getContactSettings() async {
    logApi(function: 'getContactSettings()', request: {});
    try {
      final doc = await _db.collection('setting').doc('contactUs').get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final phone = data['directCall']?.toString() ?? '';
        final whatsapp = data['whatsapp']?.toString() ?? '';

        logApi(
          function: 'getContactSettings()',
          response: {'directCall': phone, 'whatsapp': whatsapp},
        );
        return {'phone': phone, 'whatsapp': whatsapp};
      }
      return {'phone': '', 'whatsapp': ''};
    } on FirebaseAuthException catch (e) {
      logApi(function: 'getContactSettings()', error: e);
      rethrow;
    } catch (e) {
      logApi(function: 'getContactSettings()', error: e);
      return {'phone': '', 'whatsapp': ''};
    }
  }

  // ─── Projects ───────────────────────────────────────────────────────────────

  static Future<(List<Project>, DocumentSnapshot?)> getProjects({
    DocumentSnapshot? lastDocument,
    int limit = 10,
    bool? isFeatured,
  }) async {
    logApi(
      function: 'getProjects()',
      request: {'limit': limit, 'isFeatured': isFeatured},
    );
    try {
      var query = _db.collection('projects').where('isActive', isEqualTo: true);

      if (isFeatured != null) {
        query = query.where('isFeatured', isEqualTo: isFeatured);
      }

      query = query.limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      final docs = snapshot.docs;
      final newLastDoc = docs.isNotEmpty ? docs.last : null;

      logApi(
        function: 'getProjects()',
        response: '${docs.length} projects retrieved',
      );
      return (
        docs
            .map((doc) => Project.fromJson({'id': doc.id, ...doc.data()}))
            .toList(),
        newLastDoc,
      );
    } on FirebaseAuthException catch (e) {
      logApi(function: 'getProjects()', error: e);
      rethrow;
    } catch (e) {
      logApi(function: 'getProjects()', error: e);
      rethrow;
    }
  }

  static Future<Project?> getProject(String projectId) async {
    logApi(function: 'getProject()', request: {'projectId': projectId});
    try {
      final doc = await _db.collection('projects').doc(projectId).get();
      if (!doc.exists) {
        logApi(function: 'getProject()', response: 'Not found');
        return null;
      }

      final data = doc.data()!;
      if (data['isActive'] != true) {
        logApi(function: 'getProject()', response: 'Project is inactive');
        return null;
      }

      logApi(function: 'getProject()', response: 'Found');
      return Project.fromJson({'id': doc.id, ...data});
    } on FirebaseAuthException catch (e) {
      logApi(function: 'getProject()', error: e);
      rethrow;
    } catch (e) {
      logApi(function: 'getProject()', error: e);
      rethrow;
    }
  }

  // ─── Plots ──────────────────────────────────────────────────────────────────

  static Future<List<Plot>> getPlots(String projectId) async {
    logApi(function: 'getPlots()', request: {'projectId': projectId});
    try {
      if (mockGetPlots != null) return mockGetPlots!(projectId);
      final snapshot = await _db
          .collection('plots')
          .where('projectId', isEqualTo: projectId)
          .where('isActive', isEqualTo: true)
          .orderBy('plotNumber')
          .get();
      logApi(
        function: 'getPlots()',
        response: '${snapshot.docs.length} plots retrieved',
      );
      return snapshot.docs.map((doc) => _plotFromDoc(doc)).toList();
    } on FirebaseAuthException catch (e) {
      logApi(function: 'getPlots()', error: e);
      rethrow;
    } catch (e) {
      logApi(function: 'getPlots()', error: e);
      rethrow;
    }
  }

  /// Stream of plots for a given project — used for real-time status updates.
  static Stream<List<Plot>> watchPlots(String projectId) {
    logApi(function: 'watchPlots()', request: {'projectId': projectId});
    return _db
        .collection('plots')
        .where('projectId', isEqualTo: projectId)
        .where('isActive', isEqualTo: true)
        .orderBy('plotNumber')
        .snapshots()
        .map((snap) {
          logApi(
            function: 'watchPlots()',
            response: '${snap.docs.length} plots updated',
          );
          return snap.docs.map((doc) => _plotFromDoc(doc)).toList();
        })
        .handleError((error) {
          logApi(function: 'watchPlots()', error: error);
        });
  }

  static Future<Plot?> getPlot(String plotId) async {
    logApi(function: 'getPlot()', request: {'plotId': plotId});
    try {
      final doc = await _db.collection('plots').doc(plotId).get();
      if (!doc.exists) {
        logApi(function: 'getPlot()', response: 'Not found');
        return null;
      }
      logApi(function: 'getPlot()', response: 'Found');
      return _plotFromDoc(doc);
    } on FirebaseAuthException catch (e) {
      logApi(function: 'getPlot()', error: e);
      rethrow;
    } catch (e) {
      logApi(function: 'getPlot()', error: e);
      rethrow;
    }
  }

  // ─── Offers ─────────────────────────────────────────────────────────────────

  static Future<(List<Offer>, DocumentSnapshot?)> getOffers({
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    logApi(function: 'getOffers()', request: {'limit': limit});
    try {
      var query = _db
          .collection('offers')
          .where('status', isEqualTo: 'ACTIVE')
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      final docs = snapshot.docs;
      final newLastDoc = docs.isNotEmpty ? docs.last : null;

      logApi(
        function: 'getOffers()',
        response: '${docs.length} offers retrieved',
      );

      var offers = docs.map((doc) => _offerFromDoc(doc)).toList();

      // Enrich with project names
      final projectIds = offers
          .map((o) => o.projectId)
          .where((id) => id != null && id.isNotEmpty)
          .toSet();

      if (projectIds.isNotEmpty) {
        try {
          final projectDocs = await Future.wait(
            projectIds.map((id) => _db.collection('projects').doc(id).get()),
          );

          final projectNames = <String, String>{};
          for (final doc in projectDocs) {
            if (doc.exists) {
              final data = doc.data()!;
              projectNames[doc.id] = BilingualHelper.get(data['name']);
            }
          }

          for (var i = 0; i < offers.length; i++) {
            if (offers[i].projectId != null &&
                projectNames.containsKey(offers[i].projectId)) {
              offers[i] = offers[i].copyWith(
                projectName: projectNames[offers[i].projectId],
              );
            }
          }
        } catch (e) {
          developer.log('Error fetching project names for offers: $e');
        }
      }

      return (offers, newLastDoc);
    } on FirebaseAuthException catch (e) {
      logApi(function: 'getOffers()', error: e);
      rethrow;
    } catch (e) {
      logApi(function: 'getOffers()', error: e);
      rethrow;
    }
  }

  static Future<Offer?> getOffer(String offerId) async {
    logApi(function: 'getOffer()', request: {'offerId': offerId});
    try {
      final doc = await _db.collection('offers').doc(offerId).get();
      if (!doc.exists) {
        logApi(function: 'getOffer()', response: 'Not found');
        return null;
      }

      final data = doc.data()!;
      if (data['status'] != 'ACTIVE') {
        logApi(function: 'getOffer()', response: 'Offer is not active');
        return null;
      }

      var offer = _offerFromDoc(doc);
      if (offer.projectId != null && offer.projectId!.isNotEmpty) {
        final projectDoc = await _db
            .collection('projects')
            .doc(offer.projectId)
            .get();
        if (projectDoc.exists) {
          offer = offer.copyWith(
            projectName: BilingualHelper.get(projectDoc.data()!['name']),
          );
        }
      }

      logApi(function: 'getOffer()', response: 'Found');
      return offer;
    } on FirebaseAuthException catch (e) {
      logApi(function: 'getOffer()', error: e);
      rethrow;
    } catch (e) {
      logApi(function: 'getOffer()', error: e);
      rethrow;
    }
  }

  // ─── Enquiries ──────────────────────────────────────────────────────────────

  static Future<void> submitEnquiry(Map<String, dynamic> data) async {
    logApi(function: 'submitEnquiry()', request: data);
    try {
      await _db.collection('customerEnquiries').add({
        ...data,
        'status': 'NEW',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      logApi(function: 'submitEnquiry()', response: 'Success');
    } on FirebaseAuthException catch (e) {
      logApi(function: 'submitEnquiry()', error: e);
      rethrow;
    } catch (e) {
      logApi(function: 'submitEnquiry()', error: e);
      rethrow;
    }
  }

  // ─── Site Visits ────────────────────────────────────────────────────────────

  static Future<void> submitSiteVisit(Map<String, dynamic> data) async {
    logApi(function: 'submitSiteVisit()', request: data);
    try {
      final batch = _db.batch();

      // Generate new ID for site visit
      final siteVisitRef = _db.collection('siteVisits').doc();

      batch.set(siteVisitRef, {
        ...data,
        'id': siteVisitRef.id,
        'status': 'NEW',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      logApi(function: 'submitSiteVisit()', response: {'id': siteVisitRef.id});
    } on FirebaseAuthException catch (e) {
      logApi(function: 'submitSiteVisit()', error: e);
      rethrow;
    } catch (e) {
      logApi(function: 'submitSiteVisit()', error: e);
      rethrow;
    }
  }

  // ─── Payments ───────────────────────────────────────────────────────────────

  /// Initiates payment via a Cloud Function.
  /// The function validates the request server-side and returns a payment URL or order ID.
  /// The client NEVER writes payment success directly to Firestore.
  static Future<Map<String, dynamic>> submitPayment(
    Map<String, dynamic> data,
  ) async {
    logApi(function: 'submitPayment()', request: data);
    try {
      if (mockSubmitPayment != null) return mockSubmitPayment!(data);
      final result = await _functions
          .httpsCallable('initiatePayment')
          .call(data);
      logApi(function: 'submitPayment()', response: result.data);
      return Map<String, dynamic>.from(result.data as Map);
    } on FirebaseAuthException catch (e) {
      logApi(function: 'submitPayment()', error: e);
      rethrow;
    } catch (e) {
      logApi(function: 'submitPayment()', error: e);
      rethrow;
    }
  }

  // ─── Private helpers ────────────────────────────────────────────────────────

  static Plot _plotFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final p = doc.data()!;
    return Plot(
      id: doc.id,
      projectId: p['projectId']?.toString() ?? '',
      plotNumber: p['plotNumber']?.toString() ?? '',
      sizeInSqFt:
          (p['size'] as num?)?.toDouble() ??
          double.tryParse(p['size']?.toString() ?? '') ??
          0.0,
      dimensions: p['dimensions']?.toString() ?? 'N/A',
      facing: p['facing']?.toString() ?? 'N/A',
      roadWidth: p['road']?.toString() ?? 'N/A',
      status: _parsePlotStatus(p['status']?.toString()),
      price: (p['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static Offer _offerFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Offer(
      id: doc.id,
      title: BilingualHelper.get(data['title']),
      description: BilingualHelper.get(data['description']),
      image: data['image']?.toString() ?? '',
      startDate: data['startDate'] != null
          ? DateTime.tryParse(data['startDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: data['endDate'] != null
          ? DateTime.tryParse(data['endDate'].toString()) ??
                DateTime.now().add(const Duration(days: 30))
          : DateTime.now().add(const Duration(days: 30)),
      status: data['status']?.toString() ?? 'ACTIVE',
      discountType: data['discountType']?.toString(),
      discountValue: (data['discountValue'] as num?)?.toDouble(),
      offerCode: data['offerCode']?.toString() ?? data['code']?.toString(),
      projectId: data['projectId']?.toString(),
      projectName: BilingualHelper.get(data['projectName']),
    );
  }

  static PlotStatus _parsePlotStatus(String? status) {
    switch (status) {
      case 'AVAILABLE':
        return PlotStatus.available;
      case 'HOLD':
        return PlotStatus.hold;
      case 'BOOKED_SOLD':
        return PlotStatus.bookedSold;
      default:
        return PlotStatus.available;
    }
  }
}

void logApi({
  required String function,
  Map<String, dynamic>? request,
  dynamic response,
  dynamic error,
}) {
  developer.log('\n=========================================');
  developer.log('🔥 FIREBASE API LOG');
  developer.log('Function: $function');
  developer.log('Header: { "source": "firebase_sdk" }'); // Simulated header

  Object? sanitize(Object? data) {
    if (data is Map) {
      final sanitized = <String, dynamic>{};
      data.forEach((key, value) {
        if (key == 'profile_image_bytes' || key == 'resume_bytes') {
          sanitized[key.toString()] = '[BASE64_DATA_TRUNCATED]';
        } else {
          sanitized[key.toString()] = sanitize(value);
        }
      });
      return sanitized;
    } else if (data is List) {
      return data.map((e) => sanitize(e)).toList();
    }
    return data;
  }

  if (request != null) {
    developer.log(
      'Request Body: ${jsonEncode(sanitize(request), toEncodable: (e) => e.toString())}',
    );
  }
  if (response != null) {
    developer.log(
      'Response: ${response is Map ? jsonEncode(sanitize(response), toEncodable: (e) => e.toString()) : response.toString()}',
    );
  }
  if (error != null) {
    developer.log('Error: $error');
  }
  developer.log('=========================================\n');
}
