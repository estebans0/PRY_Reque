import 'package:flutter/material.dart';
import '../models/wallet_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletMethods _walletMethods = WalletMethods();

  //Para asegurar que se actualice el balance
  Future<void> _refreshBalance() async {
    setState(() {}); // Fuerza la actualización del FutureBuilder
  }

  // Función para mostrar el historial de donaciones en un popup
  Future<void> _showDonationsPopup(BuildContext context) async {
    try {
      // Se obtienen todas las donaciones del usuario
      List<Map<String, dynamic>> donations =
          await _walletMethods.getAllUserDonations();

      // Se construye el contenido en formato de texto
      String content = donations.isNotEmpty
          ? donations.map((donation) {
              String formattedDate =
                  _formatDate(donation['donation_date'].toDate());
              String status =
                  donation['is_deleted'] == true ? 'Cancelada' : 'Completada';
              return 'Fecha: $formattedDate\n'
                  'Donaste ${donation['amount']} al proyecto ${donation['project_name']}\n'
                  'Estado: $status\n';
            }).join('\n\n')
          : 'No tienes donaciones registradas.';

      // Mostrar el contenido en un AlertDialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Historial de Donaciones'),
            content: SingleChildScrollView(
              child: Text(content),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el popup
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar donaciones: $e')),
      );
    }
  }

  // Método auxiliar para el formato de la fecha en día/mes/año
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}:${date.second}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
        
          // Posiciona y centra el título
          const Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Cartera Digital',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 42, 69, 105),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Cuadro principal
          Center(
            child: Container(
              width: 425,
              height: 500,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 213, 209, 184),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Contenedor para el balance
                      FutureBuilder<int>(
                        future: _walletMethods.getDigitalCurrency(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return const Text('Error al cargar el balance');
                          } else {
                            return Container(
                              width: 150,
                              height: 100,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 223, 220, 198),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Fondo actual',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text('Monedas: ${snapshot.data}'),
                                ],
                              ),
                            );
                          }
                        },
                      ),

                      // // Contenedor para las transacciones recientes
                      // FutureBuilder<List<Map<String, dynamic>>>(
                      //   future: _walletMethods.getRecentTransactions(),
                      //   builder: (context, transactionSnapshot) {
                      //     if (transactionSnapshot.connectionState ==
                      //         ConnectionState.waiting) {
                      //       return const CircularProgressIndicator();
                      //     } else if (transactionSnapshot.hasError) {
                      //       return Text(
                      //           'Error al cargar transacciones: ${transactionSnapshot.error}');
                      //     } else if (transactionSnapshot.hasData &&
                      //         transactionSnapshot.data!.isEmpty) {
                      //       return const Text('No hay transacciones recientes');
                      //     } else {
                      //       return Container(
                      //         width: 220,
                      //         height: 230,
                      //         padding: const EdgeInsets.all(16.0),
                      //         decoration: BoxDecoration(
                      //           color: const Color.fromARGB(255, 223, 220, 198),
                      //           borderRadius: BorderRadius.circular(8.0),
                      //         ),
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             const Text(
                      //               'Transacciones recientes',
                      //               style: TextStyle(
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //             const SizedBox(height: 10),
                      //             ...transactionSnapshot.data!
                      //                 .map((transaction) {
                      //               return Padding(
                      //                 padding: const EdgeInsets.symmetric(
                      //                     vertical: 4.0),
                      //                 child: Text(
                      //                   'Donaste ${transaction['amount']} al proyecto ${transaction['project_name']}',
                      //                 ),
                      //               );
                      //             }).toList(),
                      //           ],
                      //         ),
                      //       );
                      //     }
                      //   },
                      // ),
                    
                    ],
                  ),

                  const SizedBox(height: 8),
                  Row(                    
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Contenedor para las transacciones recientes
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _walletMethods.getRecentTransactions(),
                        builder: (context, transactionSnapshot) {
                          if (transactionSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (transactionSnapshot.hasError) {
                            return Text(
                                'Error al cargar transacciones: ${transactionSnapshot.error}');
                          } else if (transactionSnapshot.hasData &&
                              transactionSnapshot.data!.isEmpty) {
                            return const Text('No hay transacciones recientes');
                          } else {
                            return Container(
                              width: 220,
                              height: 230,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 223, 220, 198),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Transacciones recientes',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ...transactionSnapshot.data!
                                      .map((transaction) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Text(
                                        'Donaste ${transaction['amount']} al proyecto ${transaction['project_name']}',
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  


                  const SizedBox(height: 40),

                  // Botones de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.pushNamed(
                              context, '/buy-digital-currency');
                          if (result == true) {
                            _refreshBalance();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 135, 171, 155),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Icon(Icons.shopping_cart,
                            color: Color.fromARGB(255, 212, 209, 184)),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          _showDonationsPopup(
                              context); // Llama al popup para mostrar donaciones
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 135, 171, 155),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Icon(Icons.download,
                            color: Color.fromARGB(255, 212, 209, 184)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),


          Positioned(
            top: 30,
            left: 20,
            height: 40,
            width: 40,
            child: Tooltip(
              message: 'Volver',
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context); // Vuelve a la pantalla anterior
                },
                backgroundColor: const Color.fromARGB(255, 63, 119, 133),
                child: const Icon(Icons.arrow_back,
                    color: Color.fromARGB(255, 212, 209, 184)),
              ),
            ),
          ),
        
        ],
      ),
    );
  }
}
