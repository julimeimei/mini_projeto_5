import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

final imagePicker = ImagePicker();
FirebaseAuth auth = FirebaseAuth.instance;
DatabaseReference realTimeDatabaseRef = FirebaseDatabase.instance.ref();