import 'package:flutter/material.dart';
import '../controllers/controller.dart';

class DonationButton extends StatelessWidget {
  final Controller _controller = Controller();

  final String projectId =
      '11hlzR0n5jUF6bNcjEVW'; //ID fijo del proyecto(para probar)

  final VoidCallback
      onDonationComplete; //Callback para notificar cuando la donación esté completa

  DonationButton({required this.onDonationComplete, super.key});

  //Mostrar el popup para pedir la cantidad de la donación
  Future<void> showDonationPopup(BuildContext context) async {
    int donationAmount = 0;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, //Evitar cerrar el popup tocando fuera de él
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ingrese la cantidad a donar'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Monto de la donación"),
            onChanged: (value) {
              donationAmount = int.tryParse(value) ?? 0; //Convertir a entero
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
                    //Lógica de donación utilizando el controlador con el projectId fijo
                    await _controller.makeDonation(projectId, donationAmount);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Donación realizada con éxito')));
                    onDonationComplete(); // Llamamos al callback para refrescar el balance
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                  Navigator.of(context).pop(); // Cerrar el popup
                } else {
                  //Muestra error de monto inválido
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
