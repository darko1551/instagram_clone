import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utils/utils.dart';

import '../models/post.dart';

class DeletePost {
  Future<dynamic> deletePostDialog(
    BuildContext context,
    String postId, [
    mounted = true,
  ]) async {
    Post post = await FirestoreMethods().getPostById(postId);
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            shrinkWrap: true,
            children: ['Delete']
                .map(
                  (e) => InkWell(
                    onTap: () async {
                      String res = await FirestoreMethods().deletePost(post);
                      if (res != 'Success') {
                        if (!mounted) return;
                        showSnackBar(context, res);
                      } else {
                        if (!mounted) return;
                        showSnackBar(
                          context,
                          'Post deleted! Refresh to show changes',
                        );
                      }
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 42,
                        horizontal: 16,
                      ),
                      child: Text(e),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
