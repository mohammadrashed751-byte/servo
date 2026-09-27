import 'package:flutter/material.dart';

import 'feature/account/data/datasources/profile_local_store.dart';
import 'feature/auth/prsentation/screen/screen_one.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.profileStore});

  final ProfileLocalStore? profileStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScreenOne(),
    );
  }
}
