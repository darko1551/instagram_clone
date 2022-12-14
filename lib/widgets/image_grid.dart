import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/resources/image_overlay_actions.dart';
import 'package:instagram_clone/utils/enum_overlay_actions.dart';

class ImageGrid extends StatefulWidget {
  const ImageGrid({super.key, required this.snapshot});
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot;
  @override
  State<ImageGrid> createState() => _ImageGridState();
}

class _ImageGridState extends State<ImageGrid> {
  @override
  Widget build(BuildContext context) {
    ImageOverlayActions overlayActions = ImageOverlayActions();
    return GridView.custom(
      gridDelegate: SliverQuiltedGridDelegate(
        crossAxisCount: 4,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        repeatPattern: QuiltedGridRepeatPattern.inverted,
        pattern: const [
          QuiltedGridTile(2, 2),
          QuiltedGridTile(1, 2),
          QuiltedGridTile(1, 2),
          QuiltedGridTile(1, 2),
        ],
      ),
      childrenDelegate: SliverChildBuilderDelegate(
        childCount: widget.snapshot.data!.size,
        (context, index) {
          return GestureDetector(
            onLongPress: () => overlayActions.imageOverlay.showImageOverlay(
              context,
              widget.snapshot.data!.docs[index]['postId'],
            ),
            onLongPressEnd: (details) {
              overlayActions.actionExecute(
                context,
                overlayActions.previousState,
                widget.snapshot.data!.docs[index]['postId'],
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
              //'https://images.unsplash.com/photo-1617943133078-3ad4f4411aeb?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80',

              widget.snapshot.data!.docs[index]['postUrl'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/internal_server_error.png',
                  fit: BoxFit.cover,
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress != null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return child;
                }
              },
            ),
          );
        },
      ),
    );
  }
}
