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

  Future<void> likePost(
    String postId,
    String uid,
    List likes,
  ) async {
    try {
      if (likes.contains(uid)) {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> postComment(
    String postId,
    String text,
    String uid,
    String name,
    String profilePicture,
  ) async {
    String res = 'Something went wrong';
    try {
      String commentId = const Uuid().v1();
      if (text.isNotEmpty) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set(
          {
            'text': text,
            'profilePicture': profilePicture,
            'name': name,
            'commentId': commentId,
            'likes': [],
            'datePublished': DateTime.now(),
          },
        );
        res = 'Success';
      } else {
        res = 'Text is empty';
      }
    } catch (e) {
      res = 'Error during posting a comment';
    }
    return res;
  }

  Future<String> likeComment(
    final snap,
    String postId,
    String uId,
  ) async {
    String res = '';

    try {
      List<String> likes = getCommentLikes(snap);

      if (!likes.contains(uId)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(snap['commentId'])
            .update(
          {
            'likes': FieldValue.arrayUnion(
              [uId],
            ),
          },
        );
      } else {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(snap['commentId'])
            .update(
          {
            'likes': FieldValue.arrayRemove(
              [uId],
            ),
          },
        );
      }
      res = 'Success';
    } catch (e) {
      res = 'Something went wrong';
    }
    return res;
  }

  List<String> getCommentLikes(snap) {
    List<String> likes =
        (snap['likes'] as List).map((e) => e as String).toList();
    return likes;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getComments(String postId) {
    final snap = _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .snapshots();
    return snap;
  }

  Future<String> deletePost(Post post) async {
    String res = '';
    try {
      StorageMethods().removePostImage(post.postUrl);
      await _firestore
          .collection('posts')
          .doc(post.postId)
          .collection('comments')
          .get()
          .then(
            (value) => value.docs.forEach(
              (element) {
                _firestore
                    .collection('posts')
                    .doc(post.postId)
                    .collection('comments')
                    .doc(element.id)
                    .delete();
              },
            ),
          );

      await _firestore.collection('posts').doc(post.postId).delete();
      res = 'Success';
    } catch (e) {
      res = 'An error ocured while deleting a post';
    }
    return res;
  }
}
