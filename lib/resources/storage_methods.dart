import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> upoladImageToStorage(
    String childName,
    Uint8List file,
    bool isPost,
  ) async {
    Reference reference = _storage.ref(childName).child(_auth.currentUser!.uid);
    UploadTask task = reference.putData(file);
    TaskSnapshot taskSnapshot = await task;
    return await taskSnapshot.ref.getDownloadURL();
  }
}
