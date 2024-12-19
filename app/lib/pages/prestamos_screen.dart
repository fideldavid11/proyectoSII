import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrestamosScreen extends StatefulWidget {
  const PrestamosScreen({super.key});

  @override
  State<PrestamosScreen> createState() => _PrestamosScreenState();
}

class _PrestamosScreenState extends State<PrestamosScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('authToken') == null) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Préstamos'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Bienvenido a la sección de Préstamos'),
      ),
    );
  }
}
