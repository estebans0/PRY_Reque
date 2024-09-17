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
    setState(() {}); //Fuerza la actualización del FutureBuilder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          //Posiciona y centra el título
          Positioned(
            top: 50, //Ajusta la posición vertical
            left: 0,
            right: 0, //Para centrar el texto horizontalmente
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

          //cuadro principal
          Center(
            child: Container(
              width: 435,
              height: 360,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 213, 209, 184),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Contenedor para el balance
                      FutureBuilder<double>(
                        future: _walletMethods.getDigitalCurrency(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator(); //Muestra un cargando mientras se obtiene el balance
                          } else if (snapshot.hasError) {
                            return const Text('Error al cargar el balance');
                          } else {
                            return Container(
                              width: 150,
                              height: 100,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(
                                    255, 223, 220, 198), //Fondo de balance
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

                      //Contenedor para las transacciones recientes
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
                              width: 230,
                              height: 240,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 223, 220,
                                    198), //Fondo de transacciones recientes
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
                                  }).toList(),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  //Espaciado
                  const SizedBox(height: 40),

                  //Botones de accion
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
                        child: Icon(Icons.shopping_cart,
                            color: Color.fromARGB(255, 212, 209, 184)),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          _walletMethods.downloadDonations();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 135, 171, 155),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Icon(Icons.download,
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
                // child: Icon(Icons.arrow_back),
                // backgroundColor: Color(0xFFE0E0D6),
                backgroundColor: Color.fromARGB(255, 63, 119, 133),
                child: Icon(Icons.arrow_back, color: Color.fromARGB(255, 212, 209, 184)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
