import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final String postId;
  final datePublished;
  final String postUrl;
  final String profileImage;
  final likes;

  Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profileImage,
    required this.likes,
  });

  Map<String, dynamic> toMap() => {
        'description': description,
        'uid': uid,
        'username': username,
        'postId': postId,
        'datePublished': datePublished,
        'postUrl': postUrl,
        'profileImage': profileImage,
        'likes': likes,
      };

  static Post fromMap(Map<String, dynamic> postMap) {
    final post = Post(
      description: postMap['description'],
      uid: postMap['uid'],
      username: postMap['username'],
      postId: postMap['postId'],
      datePublished: postMap['datePublished'],
      postUrl: postMap['postUrl'],
      profileImage: postMap['profileImage'],
      likes: postMap['likes'],
    );
    return post;
  }

  static Post fromSnap(DocumentSnapshot snapshot) {
    final snapshotMap = snapshot.data() as Map<String, dynamic>;
    final post = fromMap(snapshotMap);
    return post;
  }
}
