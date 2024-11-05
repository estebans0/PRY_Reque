import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsModel{

    // plantillas de mensajes
    final String registerMsg = '''¡Muchas gracias por unirte a la comunidad de Innovafund! 
    Nuestra plataforma te ofrece todas las herramientas necesarias para crear tu  proyecto y conectar con miles de personas que están dispuestas a apoyar tus ideas. \n
    ¡Mucha suerte!''';
    final String updateMsg = '''Se ha actualizado la información de tu proyecto
    Ingresa a Innovafund para ver estos cambios.''';
    final String thankDonor = '''¡Muchas gracias por donar al proyecto, Tu donación está haciendo la diferencia!''';
    final String notifyOwner = '''¡Has recibido una nueva donacion en tu proyecto!
    Ingresa a Innovafund para ver el monto recaudado.''';

    final String dateLimit = ''' Estimado administrador, 
    Un proyecto esta apunto de alcanzar su fecha limite sin alcanzar el objetivo de financiacion.
    Ingresa a Innovafund para ver el proyecto.''';
    final String susProject = '''Estimado administrador, 
    Hay un proyecto con actividad sospechosa.
    Ingresa a Innovafund para ver el proyecto.''';
    final String bigDonation = '''Estimado administrador, 
    Se realizo una donacion anormalmente grande.
    Ingresa a Innovafund para ver la donacion.''';

    /*
    cuando ya este listo lo del registro agregarle el nombre completo
    */

    Future sendRegisterEmail(String email) async{
        sendEmail(email, registerMsg.trim());
    }

    Future sendUpdateEmail(String email) async{
        sendEmail(email, updateMsg.trim());
    }

    Future sendThankEmail(String email) async{
        sendEmail(email, thankDonor.trim());
    }

    Future sendNotifEmail(String email) async{
        sendEmail(email, notifyOwner.trim());
    }

    Future sendDateLimitEmail(String email) async{
        sendEmail(email, dateLimit.trim());
    }

    Future sendSusEmail(String email) async{
        sendEmail(email, susProject.trim());
    }

    Future sendBigDonationEmail(String email) async{
        sendEmail(email, bigDonation.trim());
    }

    Future sendEmail(String email, String messageContent) async{
        const serviceId = 'service_c7w9dqe';
        const templateId = 'template_3it95fn';
        const userId = 'QoBLFrMwBnZfTazhm';

        var name = email.replaceAll('@estudiantec.cr', '').replaceAll('@itcr.ac.cr', '');

        final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
        // ignore: unused_local_variable
        final response = await http.post(
            url,
            headers: {
                'origin': 'http://localhost',
                'Content-Type': 'application/json',
            },
            body: json.encode({
                'service_id': serviceId,
                'template_id': templateId,
                'user_id': userId,
                'template_params': {
                    'user_name': name, 
                    'user_email': email,
                    'message': messageContent,
                },
            }),
        );


    }
}