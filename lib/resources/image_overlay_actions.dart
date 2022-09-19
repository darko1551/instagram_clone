import 'package:flutter/material.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/screens/comments_screen.dart';
import 'package:instagram_clone/utils/enum_overlay_actions.dart';
import 'package:instagram_clone/resources/image_overlay.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../providers/user_provider.dart';
import '../screens/screens.dart';
import '../utils/delete_post.dart';

class ImageOverlayActions {
  OverlayActions previousState = OverlayActions.none;
  ImageOverlay imageOverlay = ImageOverlay();

  bool overlayButtonEvaluator(RenderBox buttonRenderBox, Offset offsetPointer) {
    Offset buttonOffset = buttonRenderBox.localToGlobal(Offset.zero);
    double yStart = buttonOffset.dy;
    double yEnd = buttonOffset.dy + buttonRenderBox.size.height;
    double xStart = buttonOffset.dx;
    double xEnd = buttonOffset.dx + buttonRenderBox.size.width;

    if ((offsetPointer.dx >= xStart && offsetPointer.dx <= xEnd) &&
        (offsetPointer.dy >= yStart && offsetPointer.dy <= yEnd)) {
      return true;
    } else {
      return false;
    }
  }

  void overlayMoveUpdate(LongPressMoveUpdateDetails details) {
    {
      int vibrationDuration = 70;
      RenderBox renderBoxFavorite =
          imageOverlay.overlayFavoriteIcon.currentContext?.findRenderObject()
              as RenderBox;
      RenderBox renderBoxProfile =
          imageOverlay.overlayProfileIcon.currentContext?.findRenderObject()
              as RenderBox;
      RenderBox renderBoxMessage =
          imageOverlay.overlayMessageIcon.currentContext?.findRenderObject()
              as RenderBox;
      RenderBox renderBoxMore = imageOverlay.overlayMoreIcon.currentContext
          ?.findRenderObject() as RenderBox;

      if (overlayButtonEvaluator(
        renderBoxFavorite,
        details.globalPosition,
      )) {
        if (previousState != OverlayActions.favorite) {
          Vibration.vibrate(duration: vibrationDuration);
        }
        previousState = OverlayActions.favorite;
      } else if (overlayButtonEvaluator(
        renderBoxProfile,
        details.globalPosition,
      )) {
        if (previousState != OverlayActions.profile) {
          Vibration.vibrate(duration: vibrationDuration);
        }
        previousState = OverlayActions.profile;
      } else if (overlayButtonEvaluator(
        renderBoxMessage,
        details.globalPosition,
      )) {
        if (previousState != OverlayActions.comments) {
          Vibration.vibrate(duration: vibrationDuration);
        }
        previousState = OverlayActions.comments;
      } else if (overlayButtonEvaluator(
        renderBoxMore,
        details.globalPosition,
      )) {
        if (previousState != OverlayActions.more) {
          Vibration.vibrate(duration: vibrationDuration);
        }

        previousState = OverlayActions.more;
      } else {
        previousState = OverlayActions.none;
      }
    }
  }

  void actionExecute(
    BuildContext context,
    OverlayActions action,
    String postId, [
    mounted = true,
  ]) async {
    Post post = await FirestoreMethods().getPostById(postId);
    if (!mounted) return;
    User user = Provider.of<UserProvider>(context, listen: false).getUser;

    switch (action) {
      case OverlayActions.favorite:
        await FirestoreMethods().likePost(post.postId, user.uid, post.likes);
        break;
      case OverlayActions.profile:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: post.uid),
          ),
        );
        break;
      case OverlayActions.comments:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CommentsScreen(post: post),
          ),
        );
        break;
      case OverlayActions.none:
        break;
      case OverlayActions.more:
        if (post.uid == user.uid) {
          DeletePost().deletePostDialog(
            context,
            post.postId,
          );
        }
    }
  }
}
