import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CorrientesScreen extends StatefulWidget {
  const CorrientesScreen({super.key});

  @override
  State<CorrientesScreen> createState() => _CorrientesScreenState();
}

class _CorrientesScreenState extends State<CorrientesScreen> {
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
        title: const Text('Cuentas Corrientes'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Bienvenido a la sección de Cuentas Corrientes'),
      ),
    );
  }
}
