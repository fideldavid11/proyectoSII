import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditosScreen extends StatefulWidget {
  const CreditosScreen({super.key});

  @override
  State<CreditosScreen> createState() => _CreditosScreenState();
}

class _CreditosScreenState extends State<CreditosScreen> {
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
        title: const Text('Tarjetas de Crédito'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/visadorada.png',
                    width: 200,
                  ),
                  const Text(
                    'Tarjeta de Crédito Visa Gold',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Column(
                  children: [
                    Icon(Icons.attach_money, size: 30, color: Colors.black),
                    Text('Costo Emisión',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('RD\$5,000.00'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.credit_card, size: 30, color: Colors.black),
                    Text('Plástico Adicional',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('RD\$5,000.00'),
                  ],
                ),
              ],
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Beneficios',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text('• 80% del límite disponible para retiro en efectivo.'),
                  Text('• Programa de doble acumulación Puntos.'),
                  Text('• Plan de financiamiento.'),
                  Text('• Seguros opcionales.'),
                  Text('• Cuenta Protegida.'),
                  Text('• Seguro de Accidentes de Viaje.'),
                ],
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Productos relacionados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildRelatedProduct('Visa Clásica', Colors.blue),
                _buildRelatedProduct('Visa Platinum', Colors.grey),
                _buildRelatedProduct('Visa Infinite', Colors.black),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, '/solicitud'); // Navega a la nueva ruta
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Realizar Solicitud'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedProduct(String title, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 50,
          color: color,
        ),
        const SizedBox(height: 5),
        Text(title),
      ],
    );
  }
}
