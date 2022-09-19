import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:provider/provider.dart';

class ImageOverlay {
  GlobalKey overlayFavoriteIcon = GlobalKey();
  GlobalKey overlayProfileIcon = GlobalKey();
  GlobalKey overlayMessageIcon = GlobalKey();
  GlobalKey overlayMoreIcon = GlobalKey();

  late Post post;
  late User userPost;
  late User currentUser;
  late OverlayState? overlayState;
  late OverlayEntry overlayEntry;

  void removeImageOverlay() {
    overlayEntry.remove();
  }

  bool checkIfLiked(
    AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot,
  ) {
    return (snapshot.data!['likes'] as List).contains(currentUser.uid);
  }

  void showImageOverlay(
    BuildContext context,
    String postId, [
    mounted = true,
  ]) async {
    post = await FirestoreMethods().getPostById(postId);
    userPost = await FirestoreMethods().getUserById(post.uid);
    if (!mounted) return;
    currentUser = Provider.of<UserProvider>(context, listen: false).getUser;
    overlayState = Overlay.of(context);

    Stream<DocumentSnapshot<Map<String, dynamic>>> getPostStream() {
      Stream<DocumentSnapshot<Map<String, dynamic>>> stream =
          FirestoreMethods().getPostByIdStream(postId);
      return stream;
    }

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Material(
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: mobileBackgroundColor,
                width: MediaQuery.of(context).size.width * 0.95,
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          child: ClipOval(
                            child: Image.network(
                              userPost.photoUrl,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Text(userPost.username),
                      ],
                    ),
                    Expanded(
                      child: Image.network(
                        post.postUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/internal_server_error.png',
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StreamBuilder(
                            stream: getPostStream(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.waiting) {
                                return Icon(
                                  !checkIfLiked(snapshot)
                                      ? Icons.favorite_outline
                                      : Icons.favorite,
                                  color: (checkIfLiked(snapshot))
                                      ? Colors.red
                                      : Colors.white,
                                  key: overlayFavoriteIcon,
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                          Icon(
                            Icons.supervisor_account_outlined,
                            key: overlayProfileIcon,
                          ),
                          Icon(
                            Icons.message_outlined,
                            key: overlayMessageIcon,
                          ),
                          Icon(
                            Icons.more_vert_outlined,
                            key: overlayMoreIcon,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState?.insert(overlayEntry);
  }
}
