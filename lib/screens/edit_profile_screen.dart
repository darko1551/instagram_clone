import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/user.dart';
import 'package:instagram_clone/resources/auth_methods.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late User user;
  late Uint8List _image;
  bool imageChanged = false;
  bool usernameChanged = false;
  bool bioChanged = false;
  late Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = getUserInfo();
    _usernameController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> getUserInfo() async {
    user = await AuthMethods().getUserDetails();
    _usernameController.text = user.username;
    _bioController.text = user.bio;
    try {
      Uint8List image = (await http.get(Uri.parse(user.photoUrl))).bodyBytes;
      setState(() {
        _image = image;
      });
    } catch (e) {
      rethrow;
    }
    return;
  }

  void selectImage() async {
    Uint8List image = await pickImage(ImageSource.gallery);
    if (_image.isNotEmpty) {
      imageChanged = true;
    }
    setState(() {
      _image = image;
    });
  }

  void submit() async {
    String imgRes = 'Success', bioRes = 'Success', usernameRes = 'Success';
    if (imageChanged) {
      imgRes = await FirestoreMethods().updateProfileImage(_image, user.uid);
    }
    if (bioChanged) {
      bioRes =
          await FirestoreMethods().updateBio(_bioController.text, user.uid);
    }
    if (usernameChanged) {
      usernameRes = await FirestoreMethods()
          .updateUsername(_usernameController.text, user.uid);
    }
    if (imgRes != 'Success' ||
        bioRes != 'Success' ||
        usernameRes != 'Success') {
      if (!mounted) return;
      showSnackBar(
        context,
        'Some changes my not be saved! Check your information',
      );
    } else {
      if (!mounted) return;
      showSnackBar(context, 'Changes saved! Refresh to see changes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: ((context, snapshot) {
        if (snapshot.connectionState != ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit profile'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  onPressed: () {
                    submit();
                  },
                  icon: const Icon(Icons.done),
                  color: Colors.blue,
                ),
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50,
                ),
                ClipOval(
                  child: CircleAvatar(
                    radius: 60,
                    child: Image.memory(
                      _image,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/default_profile_picture.png',
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    selectImage();
                  },
                  child: const Text(
                    'Change profile picture',
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Username',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextField(
                        controller: _usernameController,
                        onChanged: (value) => usernameChanged = true,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        'Bio',
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextField(
                        onChanged: (value) => usernameChanged = true,
                        maxLines: 6,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        controller: _bioController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }),
    );
  }
}
