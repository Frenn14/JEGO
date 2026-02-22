import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/color_system.dart';
import '../theme/text_system.dart';
import '../theme/spacing_system.dart';
import '../../main.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          title,
          style: AppTextStyles.title,
        ),
        leading: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: const FlutterLogo(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: () => themeProvider.toggle(),
          ),
          if (actions != null) ...actions!,
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: body,
      ),
    );
  }
}