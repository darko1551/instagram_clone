import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/widgets/post_card.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  Stream? stream;

  List<String> getFollowingList() {
    List<String> following = [''];
    following.addAll(
      Provider.of<UserProvider>(context)
          .getUser
          .following
          .map((e) => e.toString())
          .toList(),
    );
    return following;
  }

  void resetStream() {
    setState(() {
      stream = FirebaseFirestore.instance
          .collection('posts')
          .where(
            'uid',
            whereIn: getFollowingList(),
          )
          .snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    resetStream();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: SvgPicture.asset(
          'assets/ic_instagram.svg',
          color: primaryColor,
          height: 32,
        ),
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
          if (snapshot.connectionState != ConnectionState.waiting) {
            return RefreshIndicator(
              onRefresh: () {
                return Future.delayed(const Duration(seconds: 1), () {
                  Provider.of<UserProvider>(context, listen: false)
                      .refreshUser();
                  resetStream();
                });
              },
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length,
                cacheExtent: MediaQuery.of(context).size.height * 4,
                itemBuilder: (context, index) {
                  return PostCard(snap: snapshot.data!.docs[index]);
                },
              ),
            );
          } else if (!snapshot.hasData) {
            return Container();
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
