import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> upoladImageToStorage(
    String childName,
    Uint8List file,
    bool isPost,
  ) async {
    Reference reference = _storage.ref(childName).child(_auth.currentUser!.uid);

    if (isPost) {
      String id = const Uuid().v1();
      reference = reference.child(id);
    }

    UploadTask task = reference.putData(file);
    TaskSnapshot taskSnapshot = await task;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> removePostImage(String imageUrl) async {
    try {
      Reference reference = _storage.refFromURL(imageUrl);
      reference.delete();
    } catch (e) {
      rethrow;
    }
  }
}
