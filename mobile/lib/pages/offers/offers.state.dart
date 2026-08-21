import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/offer.dart';

part 'offers.state.freezed.dart';

@freezed
sealed class OffersState with _$OffersState {
  const factory OffersState({
    @Default(true) bool isLoading,
    @Default(false) bool isError,
    String? errorMessage,
    @Default([]) List<Offer> offers,
    @Default(false) bool isFetchingMore,
    @Default(true) bool hasMore,
    DocumentSnapshot? lastDocument,
  }) = _OffersState;
}
