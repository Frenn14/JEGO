import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../theme/text_system.dart';
import '../theme/spacing_system.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        // Left: Logo
        leading: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: const FlutterLogo(),
        ),

        // Center: Title
        title: Text(title, style: AppTextStyles.title),

        // Right: Theme toggle + extra actions
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: themeProvider.toggle,
          ),
          if (actions != null) ...actions!,
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}