import 'package:flutter/material.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/aligned_image_grid.dart';
import 'package:instagram_clone/widgets/button.dart';
import 'package:instagram_clone/widgets/value_description.dart';
import 'package:provider/provider.dart';

import '../models/user.dart' as user_model;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.userId = '',
  });
  final String userId;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _controller = ScrollController();
  late Future<user_model.User> displayedUser;
  late Future<int> numberOfPosts;

  Future<user_model.User> getUser() async {
    late user_model.User fetchedUser;
    try {
      if (widget.userId != '') {
        fetchedUser = await FirestoreMethods().getUserById(widget.userId);
      } else {
        fetchedUser = Provider.of<UserProvider>(context, listen: false).getUser;
      }
    } catch (e) {
      showSnackBar(context, 'An error ocured');
    }
    return fetchedUser;
  }

  @override
  void initState() {
    displayedUser = getUser();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: displayedUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(snapshot.data!.username),
              actions: [
                snapshot.data!.uid ==
                        Provider.of<UserProvider>(context).getUser.uid
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return SimpleDialog(
                                title: Text(snapshot.data!.username.toString()),
                                children: [
                                  SimpleDialogOption(
                                    onPressed: () async {
                                      String res = await AuthMethods().logOut();
                                      if (res != 'Success') {
                                        AuthMethods().logOut();
                                      } else {
                                        if (!mounted) return;
                                        showSnackBar(context, res);
                                      }
                                      if (!mounted) return;
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Log out'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.more_vert),
                      )
                    : Container()
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () {
                return Future.delayed(
                  const Duration(seconds: 1),
                  () {
                    setState(() {
                      Provider.of<UserProvider>(context, listen: false)
                          .refreshUser();
                      displayedUser = getUser();
                    });
                  },
                );
              },
              child: ListView(
                controller: _controller,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            CircleAvatar(
                              radius: 45,
                              child: ClipOval(
                                child: Image.network(
                                  width: double.infinity,
                                  height: double.infinity,
                                  snapshot.data!.photoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/default_profile_picture.png',
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress != null) {
                                      return CircularProgressIndicator.adaptive(
                                        value: (loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress
                                                .expectedTotalBytes!),
                                      );
                                    } else {
                                      return child;
                                    }
                                  },
                                ),
                              ),
                            ),
                            FutureBuilder(
                              future: numberOfPosts = FirestoreMethods()
                                  .getNumberOfPosts(snapshot.data!.uid),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState !=
                                    ConnectionState.waiting) {
                                  return ValueDescription(
                                    value: snapshot.data!.toString(),
                                    description: 'Posts',
                                  );
                                } else {
                                  return const ValueDescription(
                                    value: '-',
                                    description: 'Posts',
                                  );
                                }
                              },
                            ),
                            ValueDescription(
                              value: snapshot.data!.followers.length.toString(),
                              description: 'Followers',
                            ),
                            ValueDescription(
                              value: snapshot.data!.following.length.toString(),
                              description: 'Following',
                            ),
                          ],
                        ),
                        //description
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            right: 8,
                            top: 8,
                            bottom: 18,
                          ),
                          child: Text(
                            snapshot.data!.bio,
                            style: const TextStyle(height: 1.8),
                          ),
                        ),
                        //Buttons
                        snapshot.data!.uid !=
                                Provider.of<UserProvider>(
                                  context,
                                  listen: false,
                                ).getUser.uid
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Button(
                                    function: () async {
                                      String res = await FirestoreMethods()
                                          .startStopFollowing(
                                        snapshot.data!.uid,
                                        Provider.of<UserProvider>(
                                          context,
                                          listen: false,
                                        ).getUser.uid,
                                      )
                                          .timeout(
                                        const Duration(seconds: 3),
                                        onTimeout: () {
                                          return 'Connection timeout';
                                        },
                                      );
                                      if (res != 'Success') {
                                        if (!mounted) return;
                                        showSnackBar(context, res);
                                      }
                                      setState(() {
                                        displayedUser = getUser();
                                      });
                                    },
                                    text: snapshot.data!.followers.contains(
                                      Provider.of<UserProvider>(context)
                                          .getUser
                                          .uid,
                                    )
                                        ? 'Unfollow'
                                        : 'Follow',
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                  ),
                                  Button(
                                    function: () {},
                                    text: 'Message',
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                  ),
                                ],
                              )
                            : Button(
                                function: () {},
                                text: 'Edit profile',
                                width: double.infinity,
                              ),
                      ],
                    ),
                  ),
                  AlignedImageGrid(
                    controller: _controller,
                    uId: snapshot.data!.uid,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
