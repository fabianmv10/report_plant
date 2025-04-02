import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget tabletLayout;
  final Widget? desktopLayout;
  final Widget? wearableLayout;

  const ResponsiveLayout({
    super.key,
    required this.mobileLayout,
    required this.tabletLayout,
    this.desktopLayout,
    this.wearableLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300 && wearableLayout != null) {
          return wearableLayout!; // Para dispositivos wearable
        } else if (constraints.maxWidth < 600) {
          return mobileLayout; // Para teléfonos
        } else if (constraints.maxWidth < 1200) {
          return tabletLayout; // Para tablets
        } else {
          return desktopLayout ?? tabletLayout; // Para pantallas grandes
        }
      },
    );
  }
}