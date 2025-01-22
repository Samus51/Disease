import 'package:disease/mainApp/widgets_cartas.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prueba Cartas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CartasScreen(),
    );
  }
}

class CartasScreen extends StatelessWidget {
  const CartasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Cartas'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: CartasWidget(),
      ),
    );
  }
}
