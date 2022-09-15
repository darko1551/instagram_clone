import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/user.dart' as user_model;

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

  Future<user_model.User> getUserById(String uId) async {
    try {
      final userSnapshot = await _firestore.collection('users').doc(uId).get();
      final user_model.User user = user_model.User.fromSnap(userSnapshot);
      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getNumberOfPosts(String uId) async {
    try {
      final snap = await _firestore
          .collection('posts')
          .where('uid', isEqualTo: uId)
          .get();
      int numberOfPosts = snap.size;
      return numberOfPosts;
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPostLimitedUser(
    int limit,
    String uId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('uid', isEqualTo: uId)
          .orderBy('datePublished')
          .limit(limit)
          .get();
      return snapshot;
    } catch (e) {
      rethrow;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPostLimitedUserFromLast({
    required int limit,
    required DocumentSnapshot lastDocument,
    required String uId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('uid', isEqualTo: uId)
          .orderBy('datePublished')
          .startAfter([lastDocument['datePublished']])
          .limit(limit)
          .get();
      return snapshot;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> startFollowing(String uIdEnd, String uIdStart) async {
    String res = '';
    try {
      user_model.User user = await _firestore
          .collection('users')
          .doc(uIdStart)
          .get()
          .then((value) => user_model.User.fromSnap(value));
      bool following = user.following.contains(uIdEnd);
      if (!following) {
        //dodaj u folowere korisnika kojeg se prati
        await _firestore.collection('users').doc(uIdEnd).update({
          'followers': FieldValue.arrayUnion([uIdStart])
        });
        //dodaj u following prijavljenog korisnika
        await _firestore.collection('users').doc(uIdStart).update({
          'following': FieldValue.arrayUnion([uIdEnd])
        });
      } else {
        //ukloni folowere korisnika kojeg se prati
        await _firestore.collection('users').doc(uIdEnd).update({
          'followers': FieldValue.arrayRemove([uIdStart])
        });
        //ukloni following prijavljenog korisnika
        await _firestore.collection('users').doc(uIdStart).update({
          'following': FieldValue.arrayRemove([uIdEnd])
        });
      }
    } catch (_) {
      res = 'An error ocured';
    }
    return res;
  }
}
