import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mini_projeto_5/models/place_location.dart';
import 'package:uuid/uuid.dart';

import '../models/place.dart';
import '../utils/db_util.dart';

class PlacesModel with ChangeNotifier {
  List<Place> _items = [];
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedAddress;

  

  double? get selectedLatitude => _selectedLatitude;
  double? get selectedLongitude => _selectedLongitude;
  String? get selectedAddress => _selectedAddress;

  void selectLatitude(double latitude) {
    _selectedLatitude = latitude;
    notifyListeners();
  }

  void selectLongitude(double longitude) {
    _selectedLongitude = longitude;
    notifyListeners();
  }

  void selectAddress(String address) {
    _selectedAddress = address;
    notifyListeners();
  }

  List<Place> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }


  Place itemByIndex(int index) {
  if (_items.isEmpty || index < 0 || index >= _items.length) {
    throw RangeError('Índice $index inválido para lista de tamanho ${_items.length}');
  }
  return _items[index];
}

  Place findById(String id) {
    return _items.firstWhere((place) => place.id == id);
  }

  

  void addPlace(String title, File img, double latitude, double longitude,
    String phone, String email, String address) async {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('Users/$userId/Places');
  final newPlace = Place(
    id: Uuid().v4(),
    title: title,
    location: PlaceLocation(
        latitude: latitude, longitude: longitude, address: address),
    image: img,
    emailPlace: email,
    phonePlaceContact: phone,
  );

  _items.add(newPlace);
  
  // SQLite com nomes de colunas corrigidos
  await DbUtil.insert('places', {
    'id': newPlace.id,
    'title': newPlace.title,
    'image': newPlace.image.path,
    'location_latitude': newPlace.location!.latitude,
    'location_longitude': newPlace.location!.longitude,
    'location_address': newPlace.location!.address,
    'phone': newPlace.phonePlaceContact,
    'email': newPlace.emailPlace,
  });

  // Firebase
  try {
    await _dbRef.child(newPlace.id).set({
      'id': newPlace.id,
      'title': newPlace.title,
      'image': newPlace.image.path,
      'location_latitude': newPlace.location!.latitude,
      'location_longitude': newPlace.location!.longitude,
      'location_address': newPlace.location!.address,
      'phone': newPlace.phonePlaceContact,
      'email': newPlace.emailPlace,
    });
  } catch (e) {
    print("Erro ao adicionar o lugar ao Firebase: $e");
  }

  notifyListeners();
}

  
  void updatePlace(
    String id,
    String title,
    File image,
    double latitude,
    double longitude,
    String phone,
    String email,
    String address,
  ) async {
    if (_items.isEmpty) {
      print("A lista de lugares está vazia.");
      return;
    }

    // Encontre o índice do lugar na lista local
    final placeIndex = _items.indexWhere((place) => place.id == id);
    if (placeIndex >= 0) {
      // Corrigir a verificação do índice
      // Atualize o lugar localmente
      _items[placeIndex] = Place(
        id: id,
        title: title,
        location: PlaceLocation(
          latitude: latitude,
          longitude: longitude,
          address: address,
        ),
        image: image,
        emailPlace: email,
        phonePlaceContact: phone,
      );

      // Atualize o lugar no SQLite
      await DbUtil.update(
          'places',
          {
            'id': id,
            'title': title,
            'image': image.path,
            'location_latitude': latitude,
            'location_longitude': longitude,
            'location_address': address,
            'phone': phone,
            'email': email,
          },
          'id = ?',
          [id]);
      

      // Chame a função para atualizar no Firebase
      await updatePlaceInFirebase(
          id, title, image, latitude, longitude, phone, email, address);

      notifyListeners(); 
    } else {
      print("Lugar não encontrado para atualizar.");
    }
  }

  Future<void> updatePlaceInFirebase(
    String id,
    String title,
    File image,
    double latitude,
    double longitude,
    String phone,
    String email,
    String address,
  ) async {
    try {
      // Obtendo o ID do usuário atual
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      final DatabaseReference _dbRef =
          FirebaseDatabase.instance.ref('Users/$userId/Places');

      // Atualizar os dados no Firebase
      await _dbRef.child(id).update({
        'title': title,
        'image': image.path, // Atualize o caminho da imagem
        'location_latitude': latitude,
        'location_longitude': longitude,
        'location_address': address,
        'phone': phone,
        'email': email,
      });

      print('Lugar atualizado com sucesso no Firebase.');
    } catch (e) {
      print("Erro ao atualizar o lugar no Firebase: $e");
    }
  }

  

  Future<void> loadPlaces() async {print(_items);
  final dataList = await DbUtil.getData('places');
  _items = dataList
      .map(
        (item) => Place(
          id: item['id'],
          title: item['title'],
          emailPlace: item['email'],
          phonePlaceContact: item['phone'],
          image: File(item['image']),
          location: PlaceLocation(
              latitude: item['location_latitude'],
              longitude: item['location_longitude'],
              address: item['location_address']),
        ),
      )
      .toList();
      print(_items);
  notifyListeners();
}

  Future<void> deletePlaceFromFirebase(String id) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      final DatabaseReference _dbRef =
          FirebaseDatabase.instance.ref('Users/$userId/Places');
      final ref =
          _dbRef.child(id); // Usando o ID do lugar para localizar e excluir
      await ref.remove(); // Exclui o dado no Firebase
    } catch (e) {
      print('Erro ao excluir do Firebase: $e');
    }
  }

  Future<void> deletePlace(String id) async {
    try {
      // Excluindo do Firebase
      await deletePlaceFromFirebase(id);

      // Excluindo do SQLite
      await DbUtil.deletePlaceFromSQLite(id);

      // Remover da lista local (_items)
      _items.removeWhere((place) => place.id == id);

      notifyListeners(); 
    } catch (e) {
      print('Erro ao excluir lugar: $e');
    }
  }
}
