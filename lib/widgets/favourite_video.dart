import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../provider/video_provider.dart';
import '../widgets/video_tile.dart';
import '../models/video.dart';

class FavouriteVideo extends StatefulWidget {
  const FavouriteVideo({Key? key}) : super(key: key);

  @override
  _FavouriteVideoState createState() => _FavouriteVideoState();
}

class _FavouriteVideoState extends State<FavouriteVideo> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('videos')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('video')
          .snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> videosnapshot) {
        if (VideoProvider.favourites.isEmpty)
          return Center(
              child: Text(
            'No Favourites Yet!',
            style: TextStyle(
                fontSize: 18, color: Color.fromRGBO(131, 149, 167, 1)),
          ));
        if (videosnapshot.hasError) {
          return Center(
            child: Text('Something went wrong'),
          );
        }

        if (videosnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final doc = videosnapshot.data!.docs;
        return ListView.builder(
            itemCount: doc.length,
            itemBuilder: (ctx, i) {
              List<VideoFile> videoFile = [];
              for (int j = 0; j < doc[i]["videoFile"].length; j++) {
                var e = doc[i]["videoFile"][j];
                videoFile.add(VideoFile(
                    id: e["id"],
                    link: e["link"],
                    height: e["height"],
                    width: e["width"]));
              }
              return VideoTile(
                  Video(
                      id: doc[i]["id"],
                      like: doc[i]["like"],
                      url: doc[i]["url"],
                      photographer: doc[i]["photographer"],
                      photographerUrl: doc[i]["photographerUrl"],
                      thumbnail: doc[i]["thumbnail"],
                      videoFile: videoFile,
                      videoUrl: doc[i]["videoUrl"]),
                  true);
            });
      },
    );
  }
}
