import 'package:falta_app/features/bottom_nav/bottom_navigation.dart';
import 'package:falta_app/features/home/presentation/screens/falta_bottom_nav.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainNavigation(),
    );
  }
}
