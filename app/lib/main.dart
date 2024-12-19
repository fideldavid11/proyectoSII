import 'package:app/pages/ahorro_screen.dart';
import 'package:app/pages/certificados_screen.dart';
import 'package:app/pages/corrientes_screen.dart';
import 'package:app/pages/creditos_screen.dart';
import 'package:app/pages/login.dart';
import 'package:app/pages/prestamos_screen.dart';
import 'package:app/pages/register.dart';
import 'package:app/pages/solicitud_screen.dart';
import 'package:app/pages/solicitudes_screen.dart';
import 'package:app/pages/userpage.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/login', // Página inicial de la aplicacion
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => HomePage(),
        '/ahorro': (context) => AhorroScreen(),
        '/corrientes': (context) => CorrientesScreen(),
        '/creditos': (context) => CreditosScreen(),
        '/prestamos': (context) => PrestamosScreen(),
        '/certificados': (context) => CertificadosScreen(),
        '/solicitudes': (context) => SolicitudesScreen(),
        '/solicitud': (context) => SolicitudScreen(), // Nueva ruta
      },
    );
  }
}
