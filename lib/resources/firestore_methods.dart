import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    Uint8List file,
    String description,
    String uid,
    String username,
    String profileImage,
  ) async {
    String res = 'Some error occured';

    String postId = const Uuid().v1();
    try {
      String photoUrl = await StorageMethods().upoladImageToStorage(
        'posts',
        file,
        true,
      );

      Post post = Post(
        datePublished: DateTime.now(),
        description: description,
        likes: [],
        postId: postId,
        postUrl: photoUrl,
        profileImage: profileImage,
        uid: uid,
        username: username,
      );

      _firestore.collection('posts').doc(postId).set(post.toMap());
      res = 'Success';
    } on FirebaseException catch (e) {
      res = e.toString();
    }
    return res;
  }
}
