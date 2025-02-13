import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/Widgets/MainDrawer.dart';
import 'package:school_management/controllers/auth_controller.dart';

class PageWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showDrawer;
  final List<Widget>? actions;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool automaticallyImplyLeading;

  PageWrapper({
    super.key,
    required this.title,
    required this.child,
    this.showDrawer = false,
    this.actions,
    this.scaffoldKey,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.automaticallyImplyLeading = true,
  });

  final AuthController _authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: automaticallyImplyLeading,
        actions: actions,
      ),
      drawer: showDrawer ? MainDrawer() : null,
      body: SafeArea(
        child: Obx(() {
          if (_authController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return child;
        }),
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}
