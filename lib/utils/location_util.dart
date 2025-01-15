import 'dart:convert';

import 'package:http/http.dart' as http;

const GOOGLE_API_KEY = 'AIzaSyBJen81h9Sz0_Vvs2hn2i8bvcDEb8WCKTs';

class LocationUtil {
  static String generateLocationPreviewImage({
    double? latitude,
    double? longitude,
  }) {
    //https://developers.google.com/maps/documentation/maps-static/overview
    //https://pub.dev/packages/google_maps_flutter
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }

  static Future<String?> generateAddress({
    double? latitude,
    double? longitude,
  }) async {
    // URL da API do Google
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$GOOGLE_API_KEY';

    // Fazer a requisição GET
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Se a resposta for bem-sucedida, parse o JSON
      final data = json.decode(response.body);

      // Verifique se há resultados
      if (data['results'] != null && data['results'].isNotEmpty) {
        // Pega o primeiro resultado e o endereço formatado
        return data['results'][0]['formatted_address'];
      } else {
        // Caso não haja resultados
        return 'Endereço não encontrado';
      }
    } else {
      // Se houver erro na requisição
      return 'Erro ao obter o endereço';
    }
  }
}
