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
}
