import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/resources/image_overlay_actions.dart';
import 'package:instagram_clone/screens/profile_feed_screen.dart';
import 'package:instagram_clone/utils/delete_post.dart';
import 'package:instagram_clone/utils/enum_overlay_actions.dart';

class AlignedImageGrid extends StatefulWidget {
  const AlignedImageGrid({
    super.key,
    required this.controller,
    required this.uId,
  });
  final ScrollController controller;
  final String uId;
  @override
  State<AlignedImageGrid> createState() => _AlignedImageGridState();
}

class _AlignedImageGridState extends State<AlignedImageGrid> {
  List<Post> _posts = [];
  bool _noMore = false;
  late DocumentSnapshot _lastDocument;
  bool _isFetching = false;
  int firstFetch = 15;
  int otherFetches = 15;
  bool first = true;

  void getDocumentsLimited(int limit) async {
    first = false;
    var snapshot = await FirestoreMethods().getPostLimitedUser(
      limit,
      widget.uId,
    );
    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
    }
    setState(() {
      _posts = snapshot.docs.map((e) => Post.fromSnap(e)).toList();
    });
  }

  void getDocumentsFromLastLimited(int limit) async {
    var snapshot = await FirestoreMethods().getPostLimitedUserFromLast(
      lastDocument: _lastDocument,
      limit: limit,
      uId: widget.uId,
    );
    _posts.addAll(snapshot.docs.map((e) => Post.fromSnap(e)).toList());
    if (snapshot.docs.length < limit) {
      _noMore = true;
    }
    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _lastDocument = snapshot.docs.last;
      });
    }
  }

  void _scrollListener() async {
    if (_noMore) return;
    if (widget.controller.position.pixels ==
            widget.controller.position.maxScrollExtent &&
        _isFetching == false) {
      if (!mounted) return;
      setState(() {
        _isFetching = true;
      });
      getDocumentsFromLastLimited(otherFetches);
      setState(() {
        _isFetching = false;
      });
    }
  }

  @override
  void initState() {
    widget.controller.addListener(_scrollListener);
    getDocumentsLimited(firstFetch);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ImageOverlayActions overlayActions = ImageOverlayActions();
    int imagesPerRow = 3;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: (_posts.length / imagesPerRow).ceil(),
      itemBuilder: (context, index) {
        double dimension =
            MediaQuery.of(context).size.width * (0.98 / imagesPerRow);
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //IMAGE 1

            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileFeedScreen(index: index * 3),
                  ),
                ),
                onLongPress: () => overlayActions.imageOverlay.showImageOverlay(
                  context,
                  _posts[index * 3].postId,
                ),
                onLongPressEnd: (details) {
                  overlayActions.actionExecute(
                    context,
                    overlayActions.previousState,
                    _posts[index * 3].postId,
                  );
                  if (overlayActions.previousState == OverlayActions.favorite) {
                    Future.delayed(
                      const Duration(milliseconds: 600),
                      () {
                        overlayActions.imageOverlay.removeImageOverlay();
                      },
                    );
                  } else {
                    overlayActions.imageOverlay.removeImageOverlay();
                  }
                },
                onLongPressMoveUpdate: (details) =>
                    overlayActions.overlayMoveUpdate(details),
                child: Image.network(
                  _posts[index * 3].postUrl,
                  // 'https://images.unsplash.com/photo-1663125406817-932dd8c4e1b6?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=871&q=80',
                  width: dimension,
                  height: dimension,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/internal_server_error.png',
                      width: dimension,
                      height: dimension,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),

            //IMAGE 2

            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: _posts.length > (index * 3 + 1)
                  ? GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileFeedScreen(index: index * 3 + 1),
                        ),
                      ),
                      onLongPress: () =>
                          overlayActions.imageOverlay.showImageOverlay(
                        context,
                        _posts[index * 3 + 1].postId,
                      ),
                      onLongPressMoveUpdate: (details) =>
                          overlayActions.overlayMoveUpdate(details),
                      onLongPressEnd: (details) {
                        overlayActions.actionExecute(
                          context,
                          overlayActions.previousState,
                          _posts[index * 3 + 1].postId,
                        );
                        if (overlayActions.previousState ==
                            OverlayActions.favorite) {
                          Future.delayed(
                            const Duration(milliseconds: 600),
                            () {
                              overlayActions.imageOverlay.removeImageOverlay();
                            },
                          );
                        } else {
                          overlayActions.imageOverlay.removeImageOverlay();
                        }
                      },
                      onDoubleTap: () => DeletePost().deletePostDialog(
                        context,
                        _posts[index * 3 + 1].postId,
                      ),
                      child: Image.network(
                        _posts[index * 3 + 1].postUrl,
                        // 'https://images.unsplash.com/photo-1663125406817-932dd8c4e1b6?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=871&q=80',
                        width: dimension,
                        height: dimension,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/internal_server_error.png',
                            width: dimension,
                            height: dimension,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    )
                  : Container(),
            ),

            //IMAGE 3

            Padding(
              padding: const EdgeInsets.only(bottom: 2.0),
              child: _posts.length > (index * 3 + 2)
                  ? GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileFeedScreen(index: index * 3 + 2),
                        ),
                      ),
                      onDoubleTap: () => DeletePost().deletePostDialog(
                        context,
                        _posts[index * 3 + 2].postId,
                      ),
                      onLongPress: () =>
                          overlayActions.imageOverlay.showImageOverlay(
                        context,
                        _posts[index * 3 + 2].postId,
                      ),
                      onLongPressEnd: (details) {
                        overlayActions.actionExecute(
                          context,
                          overlayActions.previousState,
                          _posts[index * 3 + 2].postId,
                        );
                        if (overlayActions.previousState ==
                            OverlayActions.favorite) {
                          Future.delayed(
                            const Duration(milliseconds: 600),
                            () {
                              overlayActions.imageOverlay.removeImageOverlay();
                            },
                          );
                        } else {
                          overlayActions.imageOverlay.removeImageOverlay();
                        }
                      },
                      onLongPressMoveUpdate: (details) =>
                          overlayActions.overlayMoveUpdate(details),
                      child: Image.network(
                        _posts[index * 3 + 2].postUrl,
                        //'https://images.unsplash.com/photo-1663125406817-932dd8c4e1b6?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=871&q=80',
                        width: dimension,
                        height: dimension,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/internal_server_error.png',
                            width: dimension,
                            height: dimension,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    )
                  : Container(),
            ),
          ],
        );
      },
    );
  }
}
