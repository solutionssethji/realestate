import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'kyc.state.dart';

part 'kyc.logic.g.dart';

@riverpod
class KycLogic extends _$KycLogic {
  @override
  KycState build() {
    return const KycState();
  }

  Future<void> pickDocument(String type) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result.isNotEmpty && result.single.path != null) {
        final file = File(result.single.path!);
        final sizeInMb = file.lengthSync() / (1024 * 1024);
        if (sizeInMb > 2.0) {
          throw Exception('pdfTooLarge');
        }
        if (type == 'aadhar') {
          state = state.copyWith(aadharImage: file);
        } else if (type == 'pan') {
          state = state.copyWith(panImage: file);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitKyc({
    required String uid,
    required String aadharNumber,
    required String panNumber,
    required Map<String, dynamic> bankDetails,
    required String? currentAadharUrl,
    required String? currentPanUrl,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      String? aadharUrl = currentAadharUrl;
      String? panUrl = currentPanUrl;

      // Upload Aadhar
      if (state.aadharImage != null) {
        aadharUrl =
            await StorageService.uploadKycDocument(
              file: state.aadharImage!,
              documentType: 'aadhar',
            ) ??
            aadharUrl;
      }

      // Upload PAN
      if (state.panImage != null) {
        panUrl =
            await StorageService.uploadKycDocument(
              file: state.panImage!,
              documentType: 'pan',
            ) ??
            panUrl;
      }

      await ApiService.updateKyc(
        uid: uid,
        aadharNumber: aadharNumber,
        aadharPhotoUrl: aadharUrl,
        panNumber: panNumber,
        panPhotoUrl: panUrl,
        bankDetails: bankDetails,
      );

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }
}
