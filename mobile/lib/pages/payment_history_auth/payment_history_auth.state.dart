class PaymentHistoryAuthState {
  final bool isLoading;
  final String? verificationId;
  final String? errorMessage;

  const PaymentHistoryAuthState({
    this.isLoading = false,
    this.verificationId,
    this.errorMessage,
  });

  bool get isOtpSent => verificationId != null;

  PaymentHistoryAuthState copyWith({
    bool? isLoading,
    String? verificationId,
    String? errorMessage,
  }) {
    return PaymentHistoryAuthState(
      isLoading: isLoading ?? this.isLoading,
      verificationId: verificationId ?? this.verificationId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
