// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:mini_projeto_5/models/place_location.dart';

class Place {
  final String id;
  final String title;
  final String phonePlaceContact;
  final String emailPlace;
  final PlaceLocation? location;
  final File image;

  Place({
    required this.id,
    required this.title,
    required this.phonePlaceContact,
    required this.emailPlace,
    this.location,
    required this.image,
  });
}
