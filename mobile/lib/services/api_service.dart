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

  static void _logApi({
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

  // ─── Settings ───────────────────────────────────────────────────────────────

  static Future<Map<String, String>> getContactSettings() async {
    _logApi(function: 'getContactSettings()');
    try {
      final doc = await _db.collection('setting').doc('contactUs').get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final phone = data['directCall']?.toString() ?? '';
        final whatsapp = data['whatsapp']?.toString() ?? '';

        _logApi(
          function: 'getContactSettings()',
          response: {'directCall': phone, 'whatsapp': whatsapp},
        );
        return {'phone': phone, 'whatsapp': whatsapp};
      }
      return {'phone': '', 'whatsapp': ''};
    } on FirebaseAuthException catch (e) {
      _logApi(function: 'getContactSettings()', error: e);
      rethrow;
    } catch (e) {
      _logApi(function: 'getContactSettings()', error: e);
      return {'phone': '', 'whatsapp': ''};
    }
  }

  // ─── Projects ───────────────────────────────────────────────────────────────

  static Future<(List<Project>, DocumentSnapshot?)> getProjects({
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    _logApi(function: 'getProjects()');
    try {
      var query = _db
          .collection('projects')
          .where('isActive', isEqualTo: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();
      final docs = snapshot.docs;
      final newLastDoc = docs.isNotEmpty ? docs.last : null;

      _logApi(
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
      _logApi(function: 'getProjects()', error: e);
      rethrow;
    } catch (e) {
      _logApi(function: 'getProjects()', error: e);
      rethrow;
    }
  }

  static Future<Project?> getProject(String projectId) async {
    _logApi(function: 'getProject()', request: {'projectId': projectId});
    try {
      final doc = await _db.collection('projects').doc(projectId).get();
      if (!doc.exists) {
        _logApi(function: 'getProject()', response: 'Not found');
        return null;
      }

      final data = doc.data()!;
      if (data['isActive'] != true) {
        _logApi(function: 'getProject()', response: 'Project is inactive');
        return null;
      }

      _logApi(function: 'getProject()', response: 'Found');
      return Project.fromJson({'id': doc.id, ...data});
    } on FirebaseAuthException catch (e) {
      _logApi(function: 'getProject()', error: e);
      rethrow;
    } catch (e) {
      _logApi(function: 'getProject()', error: e);
      rethrow;
    }
  }

  // ─── Plots ──────────────────────────────────────────────────────────────────

  static Future<List<Plot>> getPlots(String projectId) async {
    _logApi(function: 'getPlots()', request: {'projectId': projectId});
    try {
      if (mockGetPlots != null) return mockGetPlots!(projectId);
      final snapshot = await _db
          .collection('plots')
          .where('projectId', isEqualTo: projectId)
          .where('isActive', isEqualTo: true)
          .orderBy('plotNumber')
          .get();
      _logApi(
        function: 'getPlots()',
        response: '${snapshot.docs.length} plots retrieved',
      );
      return snapshot.docs.map((doc) => _plotFromDoc(doc)).toList();
    } on FirebaseAuthException catch (e) {
      _logApi(function: 'getPlots()', error: e);
      rethrow;
    } catch (e) {
      _logApi(function: 'getPlots()', error: e);
      rethrow;
    }
  }

  /// Stream of plots for a given project — used for real-time status updates.
  static Stream<List<Plot>> watchPlots(String projectId) {
    _logApi(function: 'watchPlots()', request: {'projectId': projectId});
    return _db
        .collection('plots')
        .where('projectId', isEqualTo: projectId)
        .where('isActive', isEqualTo: true)
        .orderBy('plotNumber')
        .snapshots()
        .map((snap) {
          _logApi(
            function: 'watchPlots()',
            response: '${snap.docs.length} plots updated',
          );
          return snap.docs.map((doc) => _plotFromDoc(doc)).toList();
        })
        .handleError((error) {
          _logApi(function: 'watchPlots()', error: error);
        });
  }

  static Future<Plot?> getPlot(String plotId) async {
    _logApi(function: 'getPlot()', request: {'plotId': plotId});
    try {
      final doc = await _db.collection('plots').doc(plotId).get();
      if (!doc.exists) {
        _logApi(function: 'getPlot()', response: 'Not found');
        return null;
      }
      _logApi(function: 'getPlot()', response: 'Found');
      return _plotFromDoc(doc);
    } on FirebaseAuthException catch (e) {
      _logApi(function: 'getPlot()', error: e);
      rethrow;
    } catch (e) {
      _logApi(function: 'getPlot()', error: e);
      rethrow;
    }
  }

  // ─── Offers ─────────────────────────────────────────────────────────────────

  static Future<(List<Offer>, DocumentSnapshot?)> getOffers({
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    _logApi(function: 'getOffers()');
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

      _logApi(
        function: 'getOffers()',
        response: '${docs.length} offers retrieved',
      );
      return (docs.map((doc) => _offerFromDoc(doc)).toList(), newLastDoc);
    } on FirebaseAuthException catch (e) {
      _logApi(function: 'getOffers()', error: e);
      rethrow;
    } catch (e) {
      _logApi(function: 'getOffers()', error: e);
      rethrow;
    }
  }

  // ─── Enquiries ──────────────────────────────────────────────────────────────

  static Future<void> submitEnquiry(Map<String, dynamic> data) async {
    _logApi(function: 'submitEnquiry()', request: data);
    try {
      await _db.collection('customerEnquiries').add({
        ...data,
        'status': 'NEW',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _logApi(function: 'submitEnquiry()', response: 'Success');
    } on FirebaseAuthException catch (e) {
      _logApi(function: 'submitEnquiry()', error: e);
      rethrow;
    } catch (e) {
      _logApi(function: 'submitEnquiry()', error: e);
      rethrow;
    }
  }

  // ─── Site Visits ────────────────────────────────────────────────────────────

  static Future<void> submitSiteVisit(Map<String, dynamic> data) async {
    _logApi(function: 'submitSiteVisit()', request: data);
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
      _logApi(function: 'submitSiteVisit()', response: {'id': siteVisitRef.id});
    } on FirebaseAuthException catch (e) {
      _logApi(function: 'submitSiteVisit()', error: e);
      rethrow;
    } catch (e) {
      _logApi(function: 'submitSiteVisit()', error: e);
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
    _logApi(function: 'submitPayment()', request: data);
    try {
      if (mockSubmitPayment != null) return mockSubmitPayment!(data);
      final result = await _functions
          .httpsCallable('initiatePayment')
          .call(data);
      _logApi(function: 'submitPayment()', response: result.data);
      return Map<String, dynamic>.from(result.data as Map);
    } on FirebaseAuthException catch (e) {
      _logApi(function: 'submitPayment()', error: e);
      rethrow;
    } catch (e) {
      _logApi(function: 'submitPayment()', error: e);
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
      projectId: data['projectId']?.toString(),
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
