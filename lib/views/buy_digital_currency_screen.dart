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
                'Comprar Moneda Digital',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 42, 69, 105),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          //Cuadro principal
          Center(
            child: Container(
              width: 360,
              height: 250,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 212, 209, 184), //Color de fondo
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
                mainAxisSize: MainAxisSize.min,
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
                    items: ['Método 1', 'Método 2', 'Método 3']
                        .map((String method) {
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

                        //Va hacia a la pantalla de Wallet, eliminando las pantallas previas del stack
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/wallet',
                          ModalRoute.withName('/home'),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Por favor ingrese una cantidad válida'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 63, 119, 133),
                    ),
                    child: const Text(
                      'Confirmar',
                      style:
                          TextStyle(color: Color.fromARGB(255, 212, 209, 184)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //Botón de volver
          Positioned(
            top: 30,
            left: 20,
            height: 40,
            width: 40,
            child: Tooltip(
              message: 'Volver',
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context); //Vuelve a la pantalla anterior
                },
                child: Icon(Icons.arrow_back),
                backgroundColor: Color(0xFFE0E0D6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
