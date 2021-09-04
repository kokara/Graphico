import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/favourite_image.dart';
import '../widgets/favourite_video.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = "";
  var user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    getUserName();
  }

  void getUserName() async {
    var result = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    print(result['username']);
    setState(() {
      _userName = result['username'];
    });
  }

  bool isImage = true;
  void selectedItem(BuildContext ctx, item) {
    if (item == 0) {
      if (isImage) return;

      setState(() {
        isImage = true;
      });
    } else if (item == 1) {
      if (!isImage) return;

      setState(() {
        isImage = false;
      });
    } else {
      FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Hello " + _userName,
          style: TextStyle(
              fontFamily: 'Montserrat', fontWeight: FontWeight.normal),
        ),
        actions: [
          isImage
              ? Icon(
                  Icons.image_rounded,
                )
              : Icon(
                  Icons.videocam_rounded,
                ),
          PopupMenuButton(
              icon: Icon(Icons.more_vert_rounded),
              onSelected: (item) => selectedItem(context, item),
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Text(
                            'Images',
                            style: TextStyle(fontFamily: 'Montserrat'),
                          )
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 1,
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite_rounded,
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Text(
                            'Videos',
                            style: TextStyle(fontFamily: 'Montserrat'),
                          )
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Row(
                        children: [
                          Icon(
                            Icons.exit_to_app,
                          ),
                          const SizedBox(
                            width: 7,
                          ),
                          Text(
                            'Logout',
                            style: TextStyle(fontFamily: 'Montserrat'),
                          )
                        ],
                      ),
                    )
                  ]),
          /* DropdownButtonHideUnderline(
            child: DropdownButton(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).accentColor,
              ),
              items: [
                DropdownMenuItem(
                  child: Container(
                    child: Row(
                      children: [
                        Icon(
                          Icons.exit_to_app,
                          color: Theme.of(context).accentColor,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text('Logout'),
                      ],
                    ),
                  ),
                  value: 'Logout',
                ),
                DropdownMenuItem(
                  child: Container(
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          color: Theme.of(context).accentColor,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text('Images'),
                      ],
                    ),
                  ),
                  value: 'Images',
                ),
                DropdownMenuItem(
                  child: Container(
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          color: Theme.of(context).accentColor,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text('Videos'),
                      ],
                    ),
                  ),
                  value: 'Videos',
                ),
              ],
              onChanged: (identifier) {
                if (identifier == 'Logout') {
                  FirebaseAuth.instance.signOut();
                } else if (identifier == 'Images') {
                  if (!isImage) {
                    setState(() {
                      isImage = true;
                    });
                  }
                } else if (identifier == 'Videos') {
                  if (isImage) {
                    setState(() {
                      isImage = false;
                    });
                  }
                }
              },
            ),
          ),*/
        ],
      ),
      body: isImage ? FavouriteImage() : FavouriteVideo(),
    );
  }
}
