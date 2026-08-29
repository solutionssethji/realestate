import 'package:flutter/material.dart';

class AppLoadingView extends StatelessWidget {
  final double? size;

  const AppLoadingView({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      constraints: size == null
          ? null
          : BoxConstraints.tightFor(width: size, height: size),
    );
    return Center(child: indicator);
  }
}
