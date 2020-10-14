import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class Photos extends ChangeNotifier {
  static FirebaseStorage _storge =
      FirebaseStorage(storageBucket: 'gs://shops-fb193.appspot.com');
  Future<String> uplodedPicture( File imageFile) async {
    var _storageReference = FirebaseStorage().ref().child('${DateTime.now()}');
    //String fileName = _imageUrl
    var _uploadedPhoto = _storageReference.putFile(imageFile);
    var completedTask = await _uploadedPhoto.onComplete;
    dynamic downloadUrl = await completedTask.ref.getDownloadURL();
    return downloadUrl;
  }

  Future deletePhoto(String imageUrl) async {
    if (imageUrl != null) {
      StorageReference _storgefirebase =
          await FirebaseStorage.instance.getReferenceFromUrl(imageUrl);
      await _storgefirebase.delete();
    }
  }
}
