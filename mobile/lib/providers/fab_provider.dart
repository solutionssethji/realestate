import 'package:flutter_riverpod/flutter_riverpod.dart';

class FabVisibleNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void setVisible(bool value) => state = value;
}

final fabVisibleProvider = NotifierProvider<FabVisibleNotifier, bool>(FabVisibleNotifier.new);
