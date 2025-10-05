
import 'package:flutter/material.dart';

import '../../../../data/repositories_implementation/connectivity_repository_impl.dart';
import '../../../../domain/repositories/connectivity_repository.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {

  @override
  void initState() {
    super.initState();
    _init();
  }


Future<void> _init() async {
  ConnectivityRepository connectivityRepository =
      ConnectivityRepositoryImpl();
  final hasInternet = await  connectivityRepository.hasInternet;
  // Check internet connection
  if (hasInternet) {
    // Connected
  } else{
    // Disconnected
  }
}

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}