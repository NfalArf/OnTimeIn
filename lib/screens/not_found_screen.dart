import 'package:flutter/material.dart';

class NotFoundScreen extends StatelessWidget {
  // [TAMBAHAN LANGKAH 6]
  const NotFoundScreen({super.key, this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan.')),
    );
  }
}
