import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SolicitudScreen extends StatefulWidget {
  const SolicitudScreen({super.key});

  @override
  State<SolicitudScreen> createState() => _SolicitudScreenState();
}

class _SolicitudScreenState extends State<SolicitudScreen> {
  final TextEditingController _nombreCompletoController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  String? _authToken;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      print('No token found, redirecting to login');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() => _authToken = token);
    await _fetchUserData(token);
  }

  Future<void> _fetchUserData(String token) async {
    try {
      print('Fetching user data with token: $token');
      final response = await http.get(
        Uri.parse('http://192.168.0.4:7575/api/users/user/info'),
        headers: {'x-auth-token': token},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final nombres = data['user']['nombres'] ?? '';
        final apellidos = data['user']['apellidos'] ?? '';
        final email = data['user']['email'] ?? '';
        final cedula = data['user']['cedula'] ?? '';
        final userId = data['user']['_id'] ?? '';

        setState(() {
          _nombreCompletoController.text = '$nombres $apellidos';
          _emailController.text = email;
          _cedulaController.text = cedula;
          _userId = userId;
        });
      } else {
        _showError('Error al obtener los datos del usuario');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      _showError('Error de conexión al cargar los datos');
    }
  }

  Future<void> _sendCreditRequest() async {
    if (_authToken == null || _userId == null) {
      _showError('Error de autenticación');
      return;
    }

    if (_nombreCompletoController.text.trim().isEmpty) {
      _showError('El nombre completo es obligatorio');
      return;
    }

    try {
      print('Sending credit request for user ID: $_userId');
      final response = await http.post(
        Uri.parse('http://192.168.0.4:7575/api/credit/crear'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': _authToken!,
        },
        body: json.encode({
          'userId': _userId,
          'fullName': _nombreCompletoController.text,
          'email': _emailController.text,
          'cedula': _cedulaController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        _showSuccessDialog(
            "Tu Visa Gold ha sido activada y te hemos enviado un correo.");
      } else {
        _showError('Error al enviar la solicitud');
      }
    } catch (e) {
      print('Error sending credit request: $e');
      _showError('Error de conexión al enviar la solicitud');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 80.0,
                ),
                const SizedBox(height: 16.0),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Te hemos enviado un correo con más detalles.',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0096D6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 10.0),
                  ),
                  onPressed: () {
                    _nombreCompletoController.clear();
                    _emailController.clear();
                    _cedulaController.clear();

                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'Continuar',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Registrarme Luego',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitud'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Column(
                children: [
                  Icon(Icons.looks_one, size: 40, color: Colors.blue),
                  SizedBox(height: 10),
                  Text(
                    'Obtener información de Tipo identificación',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField('Nombre Completo:', _nombreCompletoController,
                readOnly: true),
            _buildTextField('Correo Electrónico:', _emailController,
                readOnly: true),
            _buildTextField('Cédula:', _cedulaController, readOnly: true),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width:
                      screenWidth * 0.4, // Ajustar el ancho según la pantalla
                  child: ElevatedButton(
                    onPressed: _sendCreditRequest,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12)),
                    child: const Text('Continuar'),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width:
                      screenWidth * 0.4, // Ajustar el ancho según la pantalla
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12)),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            readOnly: readOnly,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
