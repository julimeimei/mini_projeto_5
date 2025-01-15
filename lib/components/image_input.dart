import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;

class ImageInput extends StatefulWidget {
  final Function onSelectImage;

  ImageInput(this.onSelectImage);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  // Capturando Imagem
  File? _storedImage;

  // Função para tirar foto com a câmera
  _takePicture() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imageFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    if (imageFile == null) return;

    setState(() {
      _storedImage = File(imageFile.path);
    });

    _saveImage(imageFile);
  }

  // Função para selecionar imagem da galeria
  _selectFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    XFile? imageFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );

    if (imageFile == null) return;

    setState(() {
      _storedImage = File(imageFile.path);
    });

    _saveImage(imageFile);
  }

  // Função para salvar a imagem escolhida
  _saveImage(XFile imageFile) async {
    // Pegar pasta que posso salvar documentos
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    String fileName = path.basename(imageFile.path);
    final savedImage = await File(imageFile.path).copy(
      '${appDir.path}/$fileName',
    );
    widget.onSelectImage(savedImage);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 180,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          alignment: Alignment.center,
          // Verificar se tem imagem
          child: _storedImage != null
              ? Image.file(
                  _storedImage!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : Text('Nenhuma Imagem!'),
        ),
        SizedBox(width: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Botão para tirar foto
                TextButton.icon(
                  icon: Icon(Icons.camera),
                  label: Text('Tirar foto'),
                  onPressed: _takePicture,
                ),
                // Botão para selecionar da galeria
                TextButton.icon(
                  icon: Icon(Icons.photo),
                  label: Text('Galeria'),
                  onPressed: _selectFromGallery,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
