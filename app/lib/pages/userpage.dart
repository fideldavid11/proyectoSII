import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app/pages/ahorro_screen.dart';
import 'package:app/pages/corrientes_screen.dart';
import 'package:app/pages/creditos_screen.dart';
import 'package:app/pages/prestamos_screen.dart';
import 'package:app/pages/certificados_screen.dart';
import 'package:app/pages/solicitudes_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  _getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('authToken');

    if (authToken == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.4:7575/api/users/user/info'),
        headers: {'x-auth-token': authToken},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          userName = '${data['user']['nombres']} ${data['user']['apellidos']}';
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              color: Colors.blue,
              child: Text(
                'Hola, ${userName ?? "Usuario"} 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),
            _menuItem(
              Icons.savings,
              'Cuentas de Ahorro',
              onTap: () => _navigateTo(context, const AhorroScreen()),
            ),
            _menuItem(
              Icons.account_balance_wallet,
              'Cuentas Corrientes',
              onTap: () => _navigateTo(context, const CorrientesScreen()),
            ),
            _menuItem(
              Icons.credit_card,
              'Tarjetas de Crédito',
              onTap: () => _navigateTo(context, const CreditosScreen()),
            ),
            _menuItem(
              Icons.attach_money,
              'Préstamos',
              onTap: () => _navigateTo(context, const PrestamosScreen()),
            ),
            _menuItem(
              Icons.workspace_premium,
              'Certificados',
              onTap: () => _navigateTo(context, const CertificadosScreen()),
            ),
            _menuItem(
              Icons.assignment,
              'Mis Solicitudes',
              onTap: () => _navigateTo(context, const SolicitudesScreen()),
            ),

            const SizedBox(height: 20),
            // Botón de cerrar sesión
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : const Center(
              child: Text(
                'Bienvenido a Smart Banking',
                style: TextStyle(fontSize: 18),
              ),
            ),
    );
  }

  Widget _menuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
