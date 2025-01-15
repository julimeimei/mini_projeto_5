import 'package:flutter/material.dart';
import 'package:mini_projeto_5/models/place.dart';
import 'package:mini_projeto_5/provider/places_model.dart';
import 'package:mini_projeto_5/screens/place_edit_screen.dart';
import 'package:mini_projeto_5/utils/location_util.dart';
import 'package:url_launcher/url_launcher.dart'; // Importe o pacote url_launcher
import 'package:provider/provider.dart'; // Importar o Provider

class PlaceDetailScreen extends StatelessWidget {
  final Place placeInst;

  // O construtor recebe o ID do lugar
  PlaceDetailScreen(this.placeInst);

  bool _hasCallSupport = false;

  // Função para abrir o aplicativo de chamadas
  Future<void> _makePhoneCall(String phoneNumber) async {
    final String url =
        'tel:$phoneNumber'; // Formato que o URL espera para abrir o telefone
    if (await canLaunchUrl(Uri(scheme: 'tel', path: phoneNumber))) {
      await launchUrl(Uri(
          scheme: 'tel',
          path: phoneNumber)); // Tenta abrir o aplicativo de chamadas
    } else {
      throw 'Não foi possível realizar a ligação para $phoneNumber'; // Exceção caso não consiga abrir
    }
  }

  // Função para abrir o aplicativo de e-mail
  Future<void> _sendEmail(String emailAddress) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      query:
          'subject=Assunto&body=Mensagem', // Opcional: pode adicionar um assunto e corpo
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Não foi possível abrir o aplicativo de e-mail para $emailAddress';
    }
  }

  // Função para abrir a localização no Google Maps
  Future<void> _openMap(double latitude, double longitude) async {
    final Uri mapUri = Uri(
      scheme: 'geo',
      path: '$latitude,$longitude',
      query:
          'q=$latitude,$longitude', // Marca a localização como ponto de interesse
    );

    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri);
    } else {
      // Fallback para Google Maps no navegador
      final googleMapsUri = Uri(
        scheme: 'https',
        host: 'www.google.com',
        path: '/maps/search/',
        queryParameters: {'api': '1', 'query': '$latitude,$longitude'},
      );
      if (await canLaunchUrl(googleMapsUri)) {
        await launchUrl(googleMapsUri);
      } else {
        throw 'Não foi possível abrir o mapa na localização ($latitude, $longitude)';
      }
    }
  }

  // Função para abrir o menu de edição
  void _onMenuItemSelected(String value, BuildContext context) async {
    switch (value) {
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PlaceEditScreen(placeInst),
          ),
        );
        break;
      case 'delete':
        final placeProvider = Provider.of<PlacesModel>(context, listen: false);
        await placeProvider.deletePlace(placeInst.id); // Deleta o lugar
        Navigator.of(context).pop(); // Volta para a tela anterior
        break;
      default:
        print('Opção desconhecida');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlacesModel>(
      builder: (ctx, placeProvider, child) {
        final place = placeProvider.findById(placeInst.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(place.title),
            backgroundColor: Colors.indigo,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) => _onMenuItemSelected(value, context),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Excluir'),
                  ),
                ],
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Exibindo a imagem do lugar
                  Image.file(
                    place.image,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                  SizedBox(height: 10),
                  // Exibindo o título do lugar
                  Text(
                    place.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Exibindo o endereço do lugar
                  Text(
                    'Endereço: ${place.location!.address}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  // Exibindo o telefone do lugar (clicável para fazer ligação)
                  GestureDetector(
                    onTap: () => _makePhoneCall(place.phonePlaceContact),
                    child: Text(
                      'Telefone: ${place.phonePlaceContact}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors
                            .blue, // Tornando o texto azul para indicar que é clicável
                        decoration:
                            TextDecoration.underline, // Adiciona o sublinhado
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Exibindo o email do lugar
                  GestureDetector(
                    onTap: () => _sendEmail(place.emailPlace),
                    child: Text(
                      'Email: ${place.emailPlace}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue, // Indicando que é clicável
                        decoration:
                            TextDecoration.underline, // Adiciona sublinhado
                      ),
                    ),
                  ),

                  SizedBox(height: 10),
                  // Exibindo a localização no mapa (latitude e longitude)
                  GestureDetector(
                    onTap: () => _openMap(
                        place.location!.latitude, place.location!.longitude),
                    child: Text(
                      'Localização: (${place.location!.latitude}, ${place.location!.longitude})',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue, // Indicando que é clicável
                        decoration:
                            TextDecoration.underline, // Adiciona sublinhado
                      ),
                    ),
                  ),

                  GestureDetector(
                      onTap: () => _openMap(
                          place.location!.latitude, place.location!.longitude),
                      child: Image.network(
                        LocationUtil.generateLocationPreviewImage(
                            latitude: place.location!.latitude,
                            longitude: place.location!.longitude),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
