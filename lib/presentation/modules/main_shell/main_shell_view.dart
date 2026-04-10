import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'main_shell_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../ai_chat/ai_chat_view.dart';

class MainShellView extends GetView<MainShellController> {
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          // Main Content
          Obx(() => IndexedStack(
                index: controller.currentIndex.value,
                children: controller.pages,
              )),
          
          // Floating AI Assistant Button
          Positioned(
            right: 20,
            bottom: 100, // Above BottomNav
            child: _buildFloatingAIButton(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: Colors.white38,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: controller.navItems,
          )),
    );
  }

  Widget _buildFloatingAIButton() {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          const AIChatView(),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        );
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primary,
              AppTheme.primary.withBlue(255),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
