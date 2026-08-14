enum PlotStatus {
  available,
  hold,
  bookedSold;

  String get displayName {
    switch (this) {
      case PlotStatus.available:
        return 'Available';
      case PlotStatus.hold:
        return 'On Hold';
      case PlotStatus.bookedSold:
        return 'Booked / Sold';
    }
  }
}
