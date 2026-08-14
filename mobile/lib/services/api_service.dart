import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../models/project.dart';
import '../models/plot.dart';
import '../models/plot_status.dart';
import '../models/offer.dart';

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
  // ─── Projects ───────────────────────────────────────────────────────────────

  static Future<List<Project>> getProjects() async {
    // Limit to 50 to avoid reading the entire collection on first load.
    final snapshot = await _db
        .collection('projects')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    return snapshot.docs
        .map((doc) => Project.fromJson({'id': doc.id, ...doc.data()}))
        .toList();
  }

  static Future<Project?> getProject(String projectId) async {
    final doc = await _db.collection('projects').doc(projectId).get();
    if (!doc.exists) return null;
    return Project.fromJson({'id': doc.id, ...doc.data()!});
  }

  // ─── Plots ──────────────────────────────────────────────────────────────────

  static Future<List<Plot>> getPlots(String projectId) async {
    if (mockGetPlots != null) return mockGetPlots!(projectId);
    final snapshot = await _db
        .collection('plots')
        .where('projectId', isEqualTo: projectId)
        .orderBy('plotNumber')
        .get();
    return snapshot.docs.map((doc) => _plotFromDoc(doc)).toList();
  }

  /// Stream of plots for a given project — used for real-time status updates.
  static Stream<List<Plot>> watchPlots(String projectId) {
    return _db
        .collection('plots')
        .where('projectId', isEqualTo: projectId)
        .orderBy('plotNumber')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => _plotFromDoc(doc)).toList());
  }

  static Future<Plot?> getPlot(String plotId) async {
    final doc = await _db.collection('plots').doc(plotId).get();
    if (!doc.exists) return null;
    return _plotFromDoc(doc);
  }

  // ─── Offers ─────────────────────────────────────────────────────────────────

  static Future<List<Offer>> getOffers() async {
    final now = Timestamp.now();
    final snapshot = await _db
        .collection('offers')
        .where('active', isEqualTo: true)
        .where('endDate', isGreaterThan: now)
        .orderBy('endDate')
        .limit(20)
        .get();
    return snapshot.docs.map((doc) => _offerFromDoc(doc)).toList();
  }

  // ─── Enquiries ──────────────────────────────────────────────────────────────

  static Future<void> submitEnquiry(Map<String, dynamic> data) async {
    await _db.collection('customerEnquiries').add({
      ...data,
      'status': 'NEW',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ─── Site Visits ────────────────────────────────────────────────────────────

  static Future<void> submitSiteVisit(Map<String, dynamic> data) async {
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

    // Create Notification tied to the site visit ID for idempotency
    final notificationRef = _db
        .collection('adminNotifications')
        .doc(siteVisitRef.id);
    batch.set(notificationRef, {
      'id': notificationRef.id,
      'type': 'SITE_VISIT',
      'relatedId': siteVisitRef.id,
      'title': 'New Site Visit Booking',
      'message':
          'New site visit booking received from ${data['customerName'] ?? 'a customer'}',
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // ─── Payments ───────────────────────────────────────────────────────────────

  /// Initiates payment via a Cloud Function.
  /// The function validates the request server-side and returns a payment URL or order ID.
  /// The client NEVER writes payment success directly to Firestore.
  static Future<Map<String, dynamic>> submitPayment(
    Map<String, dynamic> data,
  ) async {
    if (mockSubmitPayment != null) return mockSubmitPayment!(data);
    final result = await _functions.httpsCallable('initiatePayment').call(data);
    return Map<String, dynamic>.from(result.data as Map);
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
      title: data['title']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      image: data['image']?.toString() ?? '',
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : DateTime.now(),
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(days: 30)),
      isActive: data['active'] as bool? ?? true,
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
