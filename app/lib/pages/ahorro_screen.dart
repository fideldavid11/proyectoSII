import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AhorroScreen extends StatefulWidget {
  const AhorroScreen({super.key});

  @override
  State<AhorroScreen> createState() => _AhorroScreenState();
}

class _AhorroScreenState extends State<AhorroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  late PageController _pageController;
  int _currentPage = 0;
  String? _authToken;
  List<Map<String, dynamic>> _ahorros = []; // Lista para almacenar las cuentas

  @override
  void initState() {
    super.initState();
    _initializeSession();
    _pageController = PageController();
  }

  Future<void> _initializeSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() => _authToken = token);
    await _fetchUserData(token);
    await _fetchAhorros();
  }

  Future<void> _fetchUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.4:7575/api/users/user/info'),
        headers: {
          'x-auth-token': token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final nombres = data['user']['nombres'] ?? '';
        final apellidos = data['user']['apellidos'] ?? '';
        final email = data['user']['email'] ?? '';
        final userId = data['user']['_id'] ?? '';

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userId);

        setState(() {
          _fullNameController.text = '$nombres $apellidos';
          _emailController.text = email;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error al obtener los datos del usuario')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión al cargar los datos')),
      );
    }
  }

  Future<void> _fetchAhorros() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No se encontró el userId')),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.0.4:7575/api/ahorro/$userId'),
        headers: {
          'x-auth-token': _authToken ?? '',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['cuenta'] != null && data['cuenta'] is List) {
          setState(() {
            _ahorros =
                List<Map<String, dynamic>>.from(data['cuenta'].map((item) {
              return {
                'numero_cuenta': item['numeroCuenta'],
                'dinero': item['balance'],
              };
            }).toList());
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No se encontraron cuentas de ahorro')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error al obtener las cuentas de ahorro')),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error de conexión al obtener las cuentas')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        "email": _emailController.text,
        "fullName": _fullNameController.text.trim(),
      };

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('authToken');
        String? userId = prefs.getString('userId');

        if (token == null || userId == null) {
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }

        data['userId'] = userId;

        final response = await http.post(
          Uri.parse("http://192.168.0.4:7575/api/ahorro/crear"),
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': token,
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cuenta creada exitosamente")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al crear la cuenta")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error de red, intente nuevamente")),
        );
      }
    }
  }

  Widget _buildInputPage(
      String label, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.white, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              validator: (value) =>
                  value!.isEmpty ? "Este campo es obligatorio" : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: index <= _currentPage ? Colors.green : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: index < _currentPage
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text('Formulario de Ahorro'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProgressIndicator(),
            Image.asset('assets/images/2.PNG'),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildInputPage(
                      "Email", "Ingrese su email", _emailController),
                  _buildInputPage("Nombre Completo", "Ingrese su nombre",
                      _fullNameController),
                ],
              ),
            ),
            if (_currentPage == 1)
              Expanded(
                child: ListView.builder(
                  itemCount: _ahorros.length,
                  itemBuilder: (context, index) {
                    final ahorro = _ahorros[index];
                    return ListTile(
                      title:
                          Text('Número de Cuenta: ${ahorro['numero_cuenta']}'),
                      subtitle: Text('Dinero: ${ahorro['dinero']}'),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    ElevatedButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey),
                      child: const Text("Anterior"),
                    ),
                  if (_currentPage < 2)
                    ElevatedButton(
                      onPressed: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue),
                      child: const Text("Siguiente"),
                    ),
                ],
              ),
            ),
            if (_currentPage == 1)
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Enviar"),
              ),
          ],
        ),
      ),
    );
  }
}
