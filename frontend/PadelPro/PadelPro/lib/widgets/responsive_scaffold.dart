import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class ResponsiveScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color backgroundColor;

  const ResponsiveScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor = const Color(0xFFF7F8FA),
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Responsive.isDesktop || Responsive.isTablet
          ? Row(
              children: [
                if (Responsive.isDesktop)
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1A4F8A), Color(0xFF2874C8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "🎾",
                          style: TextStyle(fontSize: 80, color: Colors.white24),
                        ),
                      ),
                    ),
                  ),
                Container(
                  width: Responsive.maxContentWidth,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: body,
                ),
                if (Responsive.isDesktop)
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2874C8), Color(0xFF1A4F8A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : body,
    );
  }
}
