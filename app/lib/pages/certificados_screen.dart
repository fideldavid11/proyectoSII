import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CertificadosScreen extends StatefulWidget {
  const CertificadosScreen({super.key});

  @override
  State<CertificadosScreen> createState() => _CertificadosScreenState();
}

class _CertificadosScreenState extends State<CertificadosScreen> {
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
        title: const Text('Certificados'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Bienvenido a la sección de Certificados'),
      ),
    );
  }
}
