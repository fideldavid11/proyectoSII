import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  String? _cedulaValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (!RegExp(r'^\d{9,11}$').hasMatch(value)) {
      return 'Cédula inválida. Debe contener entre 9 y 11 dígitos';
    }
    return null;
  }

  void _onCedulaChanged(String value) {
    _cedulaController.text = value.replaceAll('-', '');
    _cedulaController.selection = TextSelection.fromPosition(
        TextPosition(offset: _cedulaController.text.length));
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final body = json.encode({
        "nombres": _nombresController.text,
        "apellidos": _apellidosController.text,
        "email": _emailController.text,
        "cedula": _cedulaController.text,
        "numero_telefonico": _telefonoController.text,
      });

      final url = Uri.parse('http://192.168.0.4:7575/api/users/register');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        final responseData = json.decode(response.body);

        if (response.statusCode == 201 &&
            responseData['msg'] == 'Usuario registrado exitosamente') {
          _showSuccessDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['msg'] ?? 'Error desconocido')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de conexión')),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 80.0,
                ),
                const SizedBox(height: 16.0),
                const Text(
                  '¡Gracias por registrarte!',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Te hemos enviado un correo con más detalles.',
                  style: TextStyle(fontSize: 16.0),
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
                    _clearForm();
                    Navigator.of(context).pop();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text(
                    'Continuar',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _clearForm() {
    _cedulaController.clear();
    _nombresController.clear();
    _apellidosController.clear();
    _emailController.clear();
    _telefonoController.clear();
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        title: const Text('Crear cuenta'),
        backgroundColor: const Color(0xFF0096D6),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0096D6), Color(0xFF80D8FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Regístrate',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0096D6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        label: 'Nombres',
                        icon: Icons.person,
                        controller: _nombresController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Por favor ingrese su nombre'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Apellidos',
                        icon: Icons.person,
                        controller: _apellidosController,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Por favor ingrese sus apellidos'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Cédula',
                        icon: Icons.credit_card,
                        controller: _cedulaController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: _onCedulaChanged,
                        validator: _cedulaValidator,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Email',
                        icon: Icons.email,
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su email';
                          }
                          if (!RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                              .hasMatch(value)) {
                            return 'Por favor ingrese un email válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Teléfono',
                        icon: Icons.phone,
                        controller: _telefonoController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su número de teléfono';
                          }
                          if (!RegExp(r'^\+?\d{10,15}$').hasMatch(value)) {
                            return 'Número de teléfono no válido';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0096D6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: const Text('Registrar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0096D6)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xFF0096D6), width: 2),
        ),
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
