import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/post_card_size.dart';
import 'package:instagram_clone/widgets/post_card.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class ProfileFeedScreen extends StatefulWidget {
  const ProfileFeedScreen({super.key, required this.index});
  final int index;

  @override
  State<ProfileFeedScreen> createState() => _ProfileFeedScreenState();
}

class _ProfileFeedScreenState extends State<ProfileFeedScreen> {
  Stream? stream;
  final ScrollController _scrollController = ScrollController();
  late double size;
  bool done = false;
  final PostCardSize _postCardSize = PostCardSize();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void resetStream(String userId) {
    setState(() {
      stream = FirebaseFirestore.instance
          .collection('posts')
          .where(
            'uid',
            isEqualTo: userId,
          )
          .orderBy('datePublished', descending: true)
          .snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;
    resetStream(user.uid);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: const Text('Posts'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.message_outlined),
          )
        ],
      ),
      body: StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          _postCardSize.heightList.clear();
          if (snapshot.connectionState != ConnectionState.waiting) {
            return RefreshIndicator(
              onRefresh: () {
                return Future.delayed(const Duration(seconds: 1), () {
                  Provider.of<UserProvider>(context, listen: false)
                      .refreshUser();
                  resetStream(user.uid);
                });
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: snapshot.data!.docs.length,
                cacheExtent: MediaQuery.of(context).size.height * 4,
                itemBuilder: (context, index) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (done) {
                      _scrollController
                          .jumpTo(_postCardSize.getSum(widget.index));
                    }
                  });
                  if (index == snapshot.data!.docs.length - 1) done = true;
                  return PostCard(snap: snapshot.data!.docs[index]);
                },
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
