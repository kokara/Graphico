import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../provider/image_provider.dart' as img;
import '../widgets/image_tile.dart';
import '../models/image.dart' as myimg;

class FavouriteImage extends StatefulWidget {
  @override
  _FavouriteImageState createState() => _FavouriteImageState();
}

class _FavouriteImageState extends State<FavouriteImage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('images')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('image')
          .snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> imagesnapshot) {
        if (img.ImageProvider.favourites.isEmpty)
          return Center(
              child: Text(
            'No Favourites Yet!',
            style: TextStyle(
                fontSize: 18, color: Color.fromRGBO(131, 149, 167, 1)),
          ));
        if (imagesnapshot.hasError) {
          return Center(
            child: Text('Something went wrong'),
          );
        }

        if (imagesnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final doc = imagesnapshot.data!.docs;
        return ListView.builder(
            itemCount: doc.length,
            itemBuilder: (ctx, i) {
              return ImageTile(
                  myimg.Image(
                      id: doc[i]['id'],
                      photographer: doc[i]['photographer'],
                      photographerUrl: doc[i]['photographerUrl'],
                      like: doc[i]['like'],
                      url: doc[i]['url'],
                      src: myimg.Sources(
                          large: doc[i]['large'],
                          original: doc[i]['original'],
                          medium: doc[i]['medium'],
                          small: doc[i]['small'])),
                  true);
            });
      },
    );
  }
}
