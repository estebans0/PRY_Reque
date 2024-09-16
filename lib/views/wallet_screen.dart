import 'package:flutter/material.dart';
import '../models/wallet_model.dart';
import 'donation_button.dart';

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
        title: const Text('Cartera Digital'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Organiza en una fila el balance y las transacciones recientes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Contenedor para el balance
                FutureBuilder<double>(
                  future: _walletMethods.getDigitalCurrency(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Muestra un cargando mientras se obtiene el balance
                    } else if (snapshot.hasError) {
                      return const Text('Error al cargar el balance');
                    } else {
                      return Container(
                        width: 150, // Ajustar el tamaño del contenedor
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Balance actual',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('Balance: ${snapshot.data}'),
                          ],
                        ),
                      );
                    }
                  },
                ),

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
                        width: 250, // Ajustar el tamaño del contenedor
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
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
                            ...transactionSnapshot.data!.map((transaction) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
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

            const SizedBox(height: 40), // Espaciado

            DonationButton(
              onDonationComplete: _refreshBalance,
            ),

            const SizedBox(height: 40), // Espaciado

            // Botones de acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                        context, '/buy-digital-currency');
                    if (result == true) {
                      _refreshBalance();
                    }
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    _walletMethods.downloadDonations();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
