import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String username;
  final String uid;
  final String email;
  final List followers;
  final List following;
  final String photoUrl;

  User({
    required this.username,
    required this.uid,
    required this.email,
    required this.followers,
    required this.following,
    required this.photoUrl,
  });

  Map<String, dynamic> toMap() => {
        'username': username,
        'uid': uid,
        'email': email,
        'followers': followers,
        'following': following,
        'photoUrl': photoUrl,
      };

  static User fromMap(Map<String, dynamic> userMap) {
    final user = User(
      email: userMap['email'],
      followers: userMap['followers'],
      following: userMap['following'],
      photoUrl: userMap['photoUrl'],
      uid: userMap['uid'],
      username: userMap['username'],
    );
    return user;
  }

  static User fromSnap(DocumentSnapshot snapshot) {
    final snapshotMap = snapshot.data() as Map<String, dynamic>;
    final user = fromMap(snapshotMap);
    return user;
  }
}
