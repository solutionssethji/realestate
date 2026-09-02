import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../l10n/app_localizations.dart';
import '../models/project.dart';
import '../models/plot.dart';
import '../models/plot_status.dart';
import '../models/offer.dart';
import '../utils/bilingual_helper.dart';
import '../utils/snackbar_utils.dart';

class PaginatedResponse<T> {
  final List<T> data;
  final DocumentSnapshot? lastDocument;

  PaginatedResponse({required this.data, this.lastDocument});
}

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
        final email = data['email']?.toString() ?? '';

        logApi(
          function: 'getContactSettings()',
          response: {'directCall': phone, 'whatsapp': whatsapp, 'email': email},
        );
        return {'phone': phone, 'whatsapp': whatsapp, 'email': email};
      }
      return {'phone': '', 'whatsapp': '', 'email': ''};
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'getContactSettings()',
      );
      return {'phone': '', 'whatsapp': '', 'email': ''};
    }
  }

  static Future<List<Map<String, dynamic>>> getReferralSettings() async {
    logApi(function: 'getReferralSettings()', request: {});
    try {
      final doc = await _db.collection('setting').doc('referral').get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final stepsList = data['steps'] as List<dynamic>? ?? [];
        return stepsList.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'getReferralSettings()',
      );
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getUserByReferralCode(
    String code,
  ) async {
    logApi(function: 'getUserByReferralCode()', request: {'code': code});
    try {
      final snapshot = await _db
          .collection('users')
          .where('referralCode', isEqualTo: code)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.data();
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'getUserByReferralCode()',
      );
      return null;
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
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(e, function: 'getProjects()');
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
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(e, function: 'getProject()');
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
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(e, function: 'getPlots()');
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
          logApi(
            function: 'watchPlots()',
            error: FirebaseAuthErrorMapper.getMessage(error.code),
          );
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
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(e, function: 'getPlot()');
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
          .where('status', whereIn: ['ACTIVE', 'Active', 'active'])
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

      final now = DateTime.now().toUtc();
      var offers = <Offer>[];
      final batch = _db.batch();
      bool hasExpired = false;

      for (var doc in docs) {
        final offer = _offerFromDoc(doc);
        if (offer.endDate.isBefore(now)) {
          batch.update(doc.reference, {'status': 'EXPIRED'});
          hasExpired = true;
        } else {
          offers.add(offer);
        }
      }

      if (hasExpired) {
        batch.commit().catchError((e) {
          developer.log('Failed to expire offers (possibly permissions): $e');
        });
      }

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
          AppSnackbar.showGlobalError(e.toString());

          developer.log('Error fetching project names for offers: $e');
        }
      }

      return (offers, newLastDoc);
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(e, function: 'getOffers()');
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
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(e, function: 'getOffer()');
      rethrow;
    }
  }

  // ─── Enquiries ──────────────────────────────────────────────────────────────

  static Future<void> submitEnquiry(Map<String, dynamic> data) async {
    logApi(function: 'submitEnquiry()', request: data);
    try {
      final batch = _db.batch();

      // Generate new ID for Enquiry
      final enquiriesRef = _db.collection('enquiries').doc();

      batch.set(enquiriesRef, {
        ...data,
        'id': enquiriesRef.id,
        'status': 'NEW',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      logApi(function: 'submitEnquiry()', response: 'Success');
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(e, function: 'submitEnquiry()');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserEnquiries(
    String customerId,
  ) async {
    logApi(function: 'getUserEnquiries()', request: {'customerId': customerId});
    try {
      final snapshot = await _db
          .collection('enquiries')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      final enquiries = snapshot.docs.map((doc) => doc.data()).toList();
      logApi(
        function: 'getUserEnquiries()',
        response: 'Fetched ${enquiries.length} enquiries',
      );
      return enquiries;
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'getUserEnquiries()',
      );
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
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'submitSiteVisit()',
      );
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserSiteVisits(
    String customerId,
  ) async {
    logApi(
      function: 'getUserSiteVisits()',
      request: {'customerId': customerId},
    );
    try {
      final snapshot = await _db
          .collection('siteVisits')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();

      final visits = snapshot.docs.map((doc) => doc.data()).toList();
      logApi(
        function: 'getUserSiteVisits()',
        response: 'Fetched ${visits.length} site visits',
      );
      return visits;
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'getUserSiteVisits()',
      );
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
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(e, function: 'submitPayment()');
      rethrow;
    }
  }

  // ─── Wishlist (Favorites) ───────────────────────────────────────────────────

  static Future<List<String>> getWishlist(String uid) async {
    logApi(function: 'getWishlist()', request: {'uid': uid});
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('wishlist')
          .get();
      final items = snapshot.docs.map((d) => d.id).toList();
      logApi(function: 'getWishlist()', response: '${items.length} items');
      return items;
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(e, function: 'getWishlist()');
      return [];
    }
  }

  static Future<void> toggleWishlist(
    String uid,
    String projectId,
    bool isFavorite,
  ) async {
    logApi(
      function: 'toggleWishlist()',
      request: {'uid': uid, 'projectId': projectId, 'isFavorite': isFavorite},
    );
    try {
      final docRef = _db
          .collection('users')
          .doc(uid)
          .collection('wishlist')
          .doc(projectId);
      if (isFavorite) {
        await docRef.set({
          'projectId': projectId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.delete();
      }
      logApi(function: 'toggleWishlist()', response: 'Success');
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'toggleWishlist()',
      );
      rethrow;
    }
  }

  // ─── Notifications (Alerts Tab) ───────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getNotifications(
    String uid, {
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    logApi(function: 'getNotifications()', request: {'uid': uid});
    try {
      var query = _db
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(limit);
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'getNotifications()',
      );
      rethrow;
    }
  }

  static Future<void> markNotificationRead(
    String uid,
    String notificationId,
  ) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'markNotificationRead()',
      );
    }
  }

  // ─── Document Locker (Vault) ────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getUserDocuments(String uid) async {
    logApi(function: 'getUserDocuments()', request: {'uid': uid});
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('documents')
          .orderBy('uploadedAt', descending: true)
          .get();
      return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'getUserDocuments()',
      );
      rethrow;
    }
  }

  static Future<void> updateKyc({
    required String uid,
    required String aadharNumber,
    required String panNumber,
    String? aadharPhotoUrl,
    String? panPhotoUrl,
    Map<String, dynamic>? bankDetails,
  }) async {
    logApi(function: 'updateKyc()', request: {'uid': uid});
    try {
      await _db.collection('users').doc(uid).update({
        'aadharNumber': aadharNumber,
        'aadharPhotoUrl': ?aadharPhotoUrl,
        'panNumber': panNumber,
        'panPhotoUrl': ?panPhotoUrl,
        if (bankDetails != null && bankDetails.isNotEmpty)
          'bankDetails': bankDetails,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      logApi(function: 'updateKyc()', response: 'Success');
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(e, function: 'updateKyc()');
      rethrow;
    }
  }

  // ─── Users ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    logApi(function: 'getUserProfile()', request: {'uid': uid});
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'getUserProfile()',
      );
      rethrow;
    }
  }

  static Stream<Map<String, dynamic>?> watchUserProfile(String uid) {
    logApi(function: 'watchUserProfile()', request: {'uid': uid});
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? {'id': doc.id, ...doc.data()!} : null);
  }

  static Future<void> createUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    logApi(function: 'createUserProfile()', request: {'uid': uid, ...data});
    try {
      await _db.collection('users').doc(uid).set(data);
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'createUserProfile()',
      );
      rethrow;
    }
  }

  static Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    logApi(function: 'updateUserProfile()', request: {'uid': uid, ...data});
    try {
      await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'updateUserProfile()',
      );
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    logApi(function: 'getUserByEmail()', request: {'email': email});
    try {
      final snapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first.data();
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'getUserByEmail()',
      );
      rethrow;
    }
  }

  // ─── User Specific Data (EMI, Properties) ──────────────────────────────────

  static Future<List<Map<String, dynamic>>> getUserPayments(String uid) async {
    logApi(function: 'getUserPayments()', request: {'uid': uid});
    try {
      final snapshot = await _db
          .collection('users')
          .doc(uid)
          .collection('payments')
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'getUserPayments()',
      );
      rethrow;
    }
  }

  static Stream<List<Map<String, dynamic>>> watchUserPayments(String uid) {
    logApi(function: 'watchUserPayments()', request: {'uid': uid});
    return _db
        .collection('users')
        .doc(uid)
        .collection('payments')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((e) => {'id': e.id, ...e.data()}).toList();
        });
  }

  static Stream<List<Map<String, dynamic>>> watchUserProperties(String uid) {
    logApi(function: 'watchUserProperties()', request: {'uid': uid});
    return _db
        .collection('assignPlots')
        .where('customerId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  static Future<Map<String, dynamic>?> getAssignPlotDetails(
    String plotId,
  ) async {
    logApi(function: 'getAssignPlotDetails()', request: {'plotId': plotId});
    try {
      final doc = await _db.collection('assignPlots').doc(plotId).get();
      if (!doc.exists) return null;

      final docData = {'id': doc.id, ...doc.data()!};

      // Populate project name
      if (docData['projectName'] == null && docData['projectId'] != null) {
        try {
          final pSnap = await _db
              .collection('projects')
              .doc(docData['projectId'] as String)
              .get();
          if (pSnap.exists && pSnap.data() != null) {
            final pData = pSnap.data()!;
            docData['projectName'] = pData['name'] is Map
                ? (pData['name']['en'] ?? pData['name'])
                : pData['name'];
          }
        } catch (_) {}
      }

      // Populate plot number and status
      if (docData['plotId'] != null &&
          (docData['plotNumber'] == null || docData['status'] == null)) {
        try {
          final ptSnap = await _db
              .collection('plots')
              .doc(docData['plotId'] as String)
              .get();
          if (ptSnap.exists && ptSnap.data() != null) {
            final ptData = ptSnap.data()!;
            docData['plotNumber'] ??= ptData['plotNumber'];
            docData['status'] ??= ptData['status'];
          }
        } catch (_) {}
      }

      // Populate applicant name and mobile
      if (docData['customerId'] != null &&
          (docData['firstApplicantName'] == null ||
              docData['firstApplicantMobile'] == null)) {
        try {
          final cSnap = await _db
              .collection('users')
              .doc(docData['customerId'] as String)
              .get();
          if (cSnap.exists && cSnap.data() != null) {
            final cData = cSnap.data()!;
            docData['firstApplicantName'] ??= cData['fullName'];
            docData['firstApplicantMobile'] ??= cData['mobileNumber'];
          }
        } catch (_) {}
      }

      return docData;
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'getAssignPlotDetails()',
      );
      rethrow;
    }
  }

  static Stream<List<Map<String, dynamic>>> watchPlotPayments(
    String plotId,
    String uid,
  ) {
    try {
      logApi(
        function: 'watchPlotPayments()',
        request: {'plotId': plotId, 'uid': uid},
      );
      return _db
          .collection('payments')
          .where('bookingId', isEqualTo: plotId)
          .where('customerId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList();
          });
    } catch (e) {
      FirebaseAuthErrorMapper().handleException(
        e,
        function: 'watchPlotPayments()',
      );
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
      facing: BilingualHelper.get(p['facing']),
      roadWidth: BilingualHelper.get(p['road'] ?? p['roadWidth']),
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
      image: data['offerImage']?.toString() ?? data['image']?.toString() ?? '',
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

  // ─── Pagination Methods ───────────────────────────────────────────────────

  static Future<PaginatedResponse<Map<String, dynamic>>>
  fetchNotificationsPagination({
    required int limit,
    DocumentSnapshot? lastDocument,
    required String userId,
  }) async {
    logApi(
      function: 'fetchNotificationsPagination()',
      request: {'userId': userId, 'limit': limit},
    );
    Query<Map<String, dynamic>> query = _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final data = snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
    final newLastDocument = snapshot.docs.isNotEmpty
        ? snapshot.docs.last
        : null;

    return PaginatedResponse(data: data, lastDocument: newLastDocument);
  }

  static Future<PaginatedResponse<Map<String, dynamic>>>
  fetchWishlistPagination({
    required int limit,
    DocumentSnapshot? lastDocument,
    required String userId,
  }) async {
    logApi(
      function: 'fetchWishlistPagination()',
      request: {'userId': userId, 'limit': limit},
    );
    Query<Map<String, dynamic>> query = _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final data = snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
    final newLastDocument = snapshot.docs.isNotEmpty
        ? snapshot.docs.last
        : null;

    return PaginatedResponse(data: data, lastDocument: newLastDocument);
  }

  static Future<PaginatedResponse<Map<String, dynamic>>>
  fetchUserPropertiesPagination({
    required int limit,
    DocumentSnapshot? lastDocument,
    required String uid,
  }) async {
    logApi(
      function: 'fetchUserPropertiesPagination()',
      request: {'uid': uid, 'limit': limit},
    );
    Query<Map<String, dynamic>> query = _db
        .collection('assignPlots')
        .where('customerId', isEqualTo: uid)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();

    final List<Map<String, dynamic>> data = await Future.wait(
      snapshot.docs.map((doc) async {
        final docData = {'id': doc.id, ...doc.data()};

        if (docData['projectName'] == null && docData['projectId'] != null) {
          try {
            final pSnap = await _db
                .collection('projects')
                .doc(docData['projectId'] as String)
                .get();
            if (pSnap.exists && pSnap.data() != null) {
              final pData = pSnap.data()!;
              docData['projectName'] = pData['name'] is Map
                  ? (pData['name']['en'] ?? pData['name'])
                  : pData['name'];
            }
          } catch (_) {}
        }

        if (docData['plotId'] != null &&
            (docData['plotNumber'] == null || docData['status'] == null)) {
          try {
            final ptSnap = await _db
                .collection('plots')
                .doc(docData['plotId'] as String)
                .get();
            if (ptSnap.exists && ptSnap.data() != null) {
              final ptData = ptSnap.data()!;
              docData['plotNumber'] ??= ptData['plotNumber'];
              docData['status'] ??= ptData['status'];
            }
          } catch (_) {}
        }

        return docData;
      }).toList(),
    );

    final newLastDocument = snapshot.docs.isNotEmpty
        ? snapshot.docs.last
        : null;

    return PaginatedResponse(data: data, lastDocument: newLastDocument);
  }

  static Future<PaginatedResponse<Map<String, dynamic>>>
  fetchUserPaymentsPagination({
    required int limit,
    DocumentSnapshot? lastDocument,
    required String uid,
  }) async {
    logApi(
      function: 'fetchUserPaymentsPagination()',
      request: {'uid': uid, 'limit': limit},
    );
    Query<Map<String, dynamic>> query = _db
        .collection('payments')
        .where('zId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    final data = snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data()})
        .toList();
    final newLastDocument = snapshot.docs.isNotEmpty
        ? snapshot.docs.last
        : null;

    return PaginatedResponse(data: data, lastDocument: newLastDocument);
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

class FirebaseAuthErrorMapper {
  static String getForgotPasswordMessage(String code) {
    final langCode = BilingualHelper.currentLangCode;
    final l10n = lookupAppLocalizations(Locale(langCode));

    switch (code) {
      case 'user-not-found' || 'invalid-email':
        return l10n.forgotPasswordInvalidEmail;
      case 'too-many-requests':
        return l10n.forgotPasswordTooManyRequests;
      default:
        return l10n.forgotPasswordFailed;
    }
  }

  static String getMessage(String code, {bool? isChangePassword}) {
    final langCode = BilingualHelper.currentLangCode;
    final l10n = lookupAppLocalizations(Locale(langCode));

    switch (code) {
      /// Email / Password Authentication
      case 'invalid-email':
        return l10n.authErrInvalidEmail;

      case 'invalid-credential':
        if (isChangePassword == true) {
          return l10n.authErrInvalidCredentialCurrent;
        }
        return l10n.authErrInvalidCredential;

      case 'wrong-password':
        return l10n.authErrWrongPassword;

      case 'user-not-found':
        return l10n.authErrUserNotFound;

      case 'user-disabled':
        return l10n.authErrUserDisabled;

      case 'email-already-in-use':
        return l10n.authErrEmailAlreadyInUse;

      case 'weak-password':
        return l10n.authErrWeakPassword;

      case 'operation-not-allowed':
        return l10n.authErrOperationNotAllowed;

      case 'too-many-requests':
        return l10n.authErrTooManyRequests;

      case 'network-request-failed':
        return l10n.authErrNetworkRequestFailed;

      case 'requires-recent-login':
        return l10n.authErrRequiresRecentLogin;

      case 'credential-already-in-use':
        return l10n.authErrCredentialAlreadyInUse;

      case 'account-exists-with-different-credential':
        return l10n.authErrAccountExistsWithDifferentCredential;

      case 'provider-already-linked':
        return l10n.authErrProviderAlreadyLinked;

      case 'no-such-provider':
        return l10n.authErrNoSuchProvider;

      case 'invalid-verification-code':
        return l10n.authErrInvalidVerificationCode;

      case 'invalid-verification-id':
        return l10n.authErrInvalidVerificationId;

      case 'session-expired':
        return l10n.authErrSessionExpired;

      case 'quota-exceeded':
        return l10n.authErrQuotaExceeded;

      case 'app-not-authorized':
        return l10n.authErrAppNotAuthorized;

      case 'invalid-api-key':
        return l10n.authErrInvalidApiKey;

      case 'internal-error':
        return l10n.authErrInternalError;

      case 'web-context-cancelled':
        return l10n.authErrWebContextCancelled;

      case 'web-storage-unsupported':
        return l10n.authErrWebStorageUnsupported;

      case 'popup-blocked':
        return l10n.authErrPopupBlocked;

      case 'auth-domain-config-required':
        return l10n.authErrAuthDomainConfigRequired;

      case 'operation-not-supported-in-this-environment':
        return l10n.authErrOperationNotSupported;

      case 'timeout':
        return l10n.authErrTimeout;

      default:
        return l10n.authErrDefault;
    }
  }

  void handleException(Object error, {String? function}) {
    String errorMessage;

    if (error is FirebaseAuthException) {
      errorMessage = FirebaseAuthErrorMapper.getMessage(error.code);
    } else if (error is FirebaseException) {
      errorMessage =
          error.message ?? 'Something went wrong. Please try again later.';
    } else {
      errorMessage = 'Something went wrong. Please try again later.';
    }

    AppSnackbar.showGlobalError(errorMessage);

    logApi(function: function ?? 'unknown', error: errorMessage);

    debugPrint('Exception: $error');
  }
}
