import 'package:flutter/material.dart';
import '../controllers/controller.dart';

class DonationButton extends StatelessWidget {
  final Controller _controller = Controller();
  final String? projectId;
  final VoidCallback onDonationComplete;

  DonationButton({
    required this.projectId,
    required this.onDonationComplete,
    super.key,
  });

  Future<void> showDonationPopup(BuildContext context) async {
    int donationAmount = 0;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ingrese la cantidad a donar'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Monto de la donación"),
            onChanged: (value) {
              donationAmount = int.tryParse(value) ?? 0;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); //Cierra el popup
              },
            ),
            TextButton(
              child: const Text('Donar'),
              onPressed: () async {
                if (donationAmount > 0) {
                  try {
                    if (projectId != null) {
                      await _controller.makeDonation(
                          projectId!, donationAmount);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Donación realizada con éxito')));

                      //Refresca el balance
                      onDonationComplete();

                      //Navega de vuelta a la pantalla principal y limpia el stack de navegación
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Project ID no válido')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingrese un monto válido')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDonationPopup(context); //Mostrar el popup para ingresar monto
      },
      child: const Text("Donar"),
    );
  }
}
