import 'dart:io';

class KycState {
  final bool isSubmitting;
  final File? aadharImage;
  final File? panImage;

  const KycState({this.isSubmitting = false, this.aadharImage, this.panImage});

  KycState copyWith({bool? isSubmitting, File? aadharImage, File? panImage}) {
    return KycState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      aadharImage: aadharImage ?? this.aadharImage,
      panImage: panImage ?? this.panImage,
    );
  }
}
