import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management/Widgets/BouncingButton.dart';
import 'package:school_management/Widgets/DashboardCards.dart';
import 'package:school_management/Widgets/PageWrapper.dart';
import 'package:school_management/Widgets/UserDetailCard.dart';
import 'package:school_management/controllers/home_controller.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late Animation<double> delayedAnimation;
  late Animation<double> muchDelayedAnimation;
  late Animation<double> leftCurve;
  late AnimationController animationController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final HomeController _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(duration: const Duration(seconds: 3), vsync: this);

    animation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController, curve: Curves.fastOutSlowIn));

    delayedAnimation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn)));

    muchDelayedAnimation = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.8, 1.0, curve: Curves.fastOutSlowIn)));

    leftCurve = Tween(begin: -1.0, end: 0.0).animate(CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut)));
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    animationController.forward();
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget? _) {
        return PageWrapper(
          title: "Dashboard",
          scaffoldKey: _scaffoldKey,
          showDrawer: true, // Activer le drawer
          child: Obx(() {
            if (_homeController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_homeController.errorMessage.value != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${_homeController.errorMessage.value}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _homeController.refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return ListView(
              children: [
                UserDetailCard(
                  rollNumber: _homeController.rollNumber,
                  name: _homeController.userName,
                  standard: _homeController.className,
                  section: _homeController.section,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30.0, 10, 30, 10),
                  child: Container(
                    alignment: const Alignment(1.0, 0),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, right: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Transform(
                            transform: Matrix4.translationValues(
                                muchDelayedAnimation.value * width, 0, 0),
                            child: const Bouncing(
                              child: DashboardCard(
                                name: "Library",
                                imgpath: "library.png",
                              ),
                            ),
                          ),
                          Transform(
                            transform: Matrix4.translationValues(
                                delayedAnimation.value * width, 0, 0),
                            child: const Bouncing(
                              child: DashboardCard(
                                name: "Track Bus",
                                imgpath: "bus.png",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      },
    );
  }
}
