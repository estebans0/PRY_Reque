import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationsModel{

    /*
    cuando ya este listo lo del registro agregarle el nombre completo
    */
    
    Future sendRegisterEmail(String email) async{
        final serviceId = 'service_c7w9dqe';
        final templateId = 'template_3it95fn';
        final userId = 'QoBLFrMwBnZfTazhm';

        final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
        final response = await http.post(
            url,
            headers: {
                'Content-Type': 'application/json',
            },
            body: json.encode({
                'service_id': serviceId,
                'template_id': templateId,
                'user_id': userId,
                'template_params': {
                    'user_name': 'usuario', //luego se cambia
                    'user_email': email,
                },
            }),
        );


    }
}