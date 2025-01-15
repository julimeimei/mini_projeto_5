import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mini_projeto_5/components/image_input.dart';
import 'package:mini_projeto_5/components/location_input.dart';
import 'package:mini_projeto_5/provider/places_model.dart';
import 'package:mini_projeto_5/models/place.dart';
import 'package:provider/provider.dart';

class PlaceEditScreen extends StatefulWidget {
  final Place place;

  // O construtor recebe o objeto Place
  PlaceEditScreen(this.place);

  @override
  _PlaceEditScreenState createState() => _PlaceEditScreenState();
}

class _PlaceEditScreenState extends State<PlaceEditScreen> {
  final _titleController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _pickedImage;

  @override
  void initState() {
    super.initState();

    // Carregando os dados do lugar para edição
    _titleController.text = widget.place.title;
    _emailController.text = widget.place.emailPlace;
    _phoneController.text = widget.place.phonePlaceContact;
    _pickedImage = widget.place.image;
  }

  void _selectImage(File pickedImage) {
    _pickedImage = pickedImage;
  }

  void _submitForm() {
    if (_titleController.text.isEmpty || _pickedImage == null) {
      return;
    }

    final placeProvider = Provider.of<PlacesModel>(context, listen: false);

    // Atualiza os dados do lugar
    placeProvider.updatePlace(
      widget.place.id,
      _titleController.text,
      _pickedImage!,
      placeProvider.selectedLatitude!,
      placeProvider.selectedLongitude!,
      _phoneController.text,
      _emailController.text,
      placeProvider.selectedAddress!,
    );

    

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Lugar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Título',
                      ),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                      ),
                    ),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Telefone',
                      ),
                    ),
                    SizedBox(height: 10),
                    ImageInput(this
                        ._selectImage), // Reutilizando o componente de seleção de imagem
                    SizedBox(height: 10),
                    LocationInput(), // Reutilizando o componente de localização
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('Salvar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                elevation: 0,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: _submitForm,
            ),
          ),
        ],
      ),
    );
  }
}
