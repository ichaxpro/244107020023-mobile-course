import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Profil Mahasiswa')),
        body: const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.school, size: 72),
            SizedBox(height: 16),
            Text('Dewi Chalissa Rania', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 9),
            Text('244107020023', style: TextStyle(fontSize: 18, color: Colors.grey, fontStyle: FontStyle.italic)),
            SizedBox(height: 7),
            Text('244107020023@student.polinema.ac.id', style: TextStyle(fontSize: 14)),
            Text('Pemrograman Mobile — Minggu 1'),
          ]),
        ),
      ),
    );
  }
}