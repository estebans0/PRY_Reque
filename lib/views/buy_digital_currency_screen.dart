// views/buy_digital_currency_screen.dart
import 'package:flutter/material.dart';
import '../models/wallet_model.dart';

class BuyDigitalCurrencyScreen extends StatefulWidget {
  const BuyDigitalCurrencyScreen({super.key});

  @override
  _BuyDigitalCurrencyScreenState createState() =>
      _BuyDigitalCurrencyScreenState();
}

class _BuyDigitalCurrencyScreenState extends State<BuyDigitalCurrencyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final WalletMethods _walletMethods = WalletMethods();
  String? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprar Moneda Digital'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Método de pago',
              ),
              value: _selectedPaymentMethod,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue;
                });
              },
              items: ['Método 1', 'Método 2', 'Método 3'].map((String method) {
                return DropdownMenuItem<String>(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && amount > 0) {
                  await _walletMethods.updateDigitalCurrency(amount);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compra realizada con éxito'),
                    ),
                  );

                  // Navegar a la pantalla de Wallet, eliminando las pantallas previas del stack
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/wallet', // Ruta de la cartera digital
                    ModalRoute.withName(
                        '/home'), // Ruta de la pantalla principal (home_screen)
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor ingrese una cantidad válida'),
                    ),
                  );
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }
}
