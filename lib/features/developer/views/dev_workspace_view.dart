import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';

class DevWorkspaceView extends GetView {
  const DevWorkspaceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Developer Workspace'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: const Center(
        child: Text(
          'Developer Workspace - Coming Soon',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}