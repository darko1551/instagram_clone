import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchedUser = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          onChanged: (value) {
            setState(() {
              searchedUser = searchController.text;
            });
          },
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search for a user',
          ),
        ),
      ),
      body: StreamBuilder<dynamic>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where(
              'username',
              isGreaterThanOrEqualTo: searchedUser,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasData && searchedUser.isNotEmpty) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        snapshot.data.docs[index]['photoUrl'],
                      ),
                    ),
                    title: Text((snapshot.data!.docs[index]['username'])),
                  );
                },
              );
            } else {
              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('datePublished', descending: true)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasData) {
                      return GridView.custom(
                        gridDelegate: SliverQuiltedGridDelegate(
                          crossAxisCount: 4,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          repeatPattern: QuiltedGridRepeatPattern.inverted,
                          pattern: const [
                            QuiltedGridTile(2, 2),
                            QuiltedGridTile(1, 1),
                            QuiltedGridTile(1, 1),
                            QuiltedGridTile(1, 2),
                          ],
                        ),
                        childrenDelegate: SliverChildBuilderDelegate(
                          childCount: snapshot.data!.docs.length,
                          (context, index) {
                            return Image.network(
                              snapshot.data!.docs[index]['postUrl'],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress != null) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else {
                                  return child;
                                }
                              },
                            );
                          },
                        ),
                      );
                    } else {
                      return Container();
                    }
                  }
                },
              );
            }
          }
        },
      ),
    );
  }
}
