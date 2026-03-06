import "package:flutter/material.dart";
import "package:flutter/services.dart";

class StatusBarWrapper extends StatelessWidget {
  final Widget child;

  const StatusBarWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: child,
    );
  }
}
