import 'package:flutter/material.dart';
import '../models/wallet_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletMethods _walletMethods = WalletMethods();

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
            FutureBuilder<double>(
              future: _walletMethods.getDigitalCurrency(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); //Muestra un cargando mientras se obtiene el balance
                } else if (snapshot.hasError) {
                  return const Text(
                      'Error al cargar el balance'); //Muestra un mensaje de error si falla
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                            'Balance actual: ${snapshot.data}'), //Muestra el balance de moneda digital
                      ),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Text('Transacciones recientes'),
                      ),
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    //Lógica para comprar moneda digital (en el futuro)
                  },
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () {
                    //Lógica para descargar las transacciones (en el futuro debatible)
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
