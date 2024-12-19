import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({super.key});

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  List<dynamic> _creditCards = [];
  bool _isLoading = true;
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
    String? userId = prefs.getString('userId');

    if (token == null || userId == null) {
      print('No token or userId found, redirecting to login');
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      _authToken = token;
      _userId = userId;
    });

    await _fetchCreditCards(_userId!, _authToken!);
  }

  Future<void> _fetchCreditCards(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.4:7575/api/credit/$userId'),
        headers: {'x-auth-token': token},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Tarjetas recibidas: $data');

        if (data is List) {
          setState(() {
            _creditCards = data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _creditCards = data['tarjetas'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        _showError('Error al obtener las tarjetas de crédito');
      }
    } catch (e) {
      print('Error fetching credit cards: $e');
      _showError('Error de conexión al obtener las tarjetas');
    }
  }

  Future<void> _deleteCard(String cardNumber) async {
    print('Intentando eliminar la tarjeta: $cardNumber');

    try {
      final response = await http.delete(
        Uri.parse('http://192.168.0.4:7575/api/credit/eliminar/$cardNumber'),
        headers: {'x-auth-token': _authToken!},
      );

      print('Respuesta de eliminación: ${response.statusCode}');

      if (response.statusCode == 200) {
        setState(() {
          _creditCards
              .removeWhere((card) => card['numeroTarjeta'] == cardNumber);
        });
        print('Tarjeta eliminada exitosamente');
        _showSuccessDialog();
      } else {
        print('Error al eliminar la tarjeta: ${response.body}');
        _showError('Error al eliminar la tarjeta');
      }
    } catch (e) {
      print('Error deleting card: $e');
      _showError('Error de conexión al eliminar la tarjeta');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
                const Text(
                  '¡Tarjeta eliminada exitosamente!',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
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
                    Navigator.of(context).pop(); // Cierra el diálogo
                  },
                  child: const Text(
                    'Aceptar',
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

  String getLastTwoDigits(String cardNumber) {
    return cardNumber.substring(cardNumber.length - 2);
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Solicitudes'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: Text('Cargando tarjetas de crédito...'))
          : _creditCards.isEmpty
              ? const Center(
                  child: Text('No tienes tarjetas de crédito asociadas.'))
              : ListView.builder(
                  itemCount: _creditCards.length,
                  itemBuilder: (context, index) {
                    var card = _creditCards[index];

                    // Obtener los dos últimos dígitos de la tarjeta
                    String lastTwoDigits =
                        getLastTwoDigits(card['numeroTarjeta']);
                    // Formatear la fecha
                    String formattedDate = formatDate(card['fechaCorte']);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage('assets/images/visadorada.png'),
                        ),
                        title: Text(
                          '**** **** **** $lastTwoDigits',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoCircle(
                                'Límite de crédito: \$${card['limiteCredito']}'),
                            _buildInfoCircle(
                                'Balance actual: \$${card['balanceActual']}'),
                            _buildInfoCircle('Fecha de corte: $formattedDate'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(
                                card['numeroTarjeta']);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoCircle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Chip(
        label: Text(text),
        backgroundColor: Colors.blueAccent,
        labelStyle: const TextStyle(color: Colors.white),
        avatar: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.info_outline, color: Colors.blueAccent),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(String cardNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text(
              '¿Seguro que deseas eliminar esta tarjeta de crédito?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteCard(cardNumber);
              },
            ),
          ],
        );
      },
    );
  }
}
