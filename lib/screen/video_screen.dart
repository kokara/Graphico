import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:graphico/models/video.dart';
import '../provider/video_provider.dart';
import '../widgets/error.dart';
import '../widgets/video_tile.dart';
import '../provider/notify_favourite.dart';

class VideoScreen extends StatefulWidget {
  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final scrollController = ScrollController();
  VideoProvider videoProvider = VideoProvider();

  @override
  void initState() {
    super.initState();
    VideoProvider.getFavourites();

    videoProvider.fetchCuratedVideos();
    print('Hii');
    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 2000) {
        videoProvider.fetchCuratedVideos();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<NotifyFavourite>();
    return StreamBuilder(
      stream: videoProvider.stream,
      builder: (context, AsyncSnapshot<List<Video>> snapshot) {
        if (snapshot.hasError)
          return Error();
        else if (!snapshot.hasData) {
          return Center(
              child: CircularProgressIndicator(
            color: Theme.of(context).accentColor,
          ));
        } else {
          return ListView.builder(
            controller: scrollController,
            itemCount: (snapshot.data?.length ?? 0) + 1,
            itemBuilder: (context, index) {
              if (index < (snapshot.data?.length ?? 0)) {
                return VideoTile(
                    snapshot.data?[index] ??
                        Video(
                          id: 1,
                          thumbnail: "",
                          url: "",
                          videoUrl: "",
                          photographer: "",
                          photographerUrl: "",
                          videoFile: [
                            VideoFile(
                                height: 1920,
                                width: 1080,
                                id: 1,
                                link:
                                    "https://player.vimeo.com/external/342571552.hd.mp4?s=6aa6f164de3812abadff3dde86d19f7a074a8a66&profile_id=175&oauth2_token_id=57447761")
                          ],
                        ),
                    false);
              } else if (!videoProvider.hasMore) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(child: Text('Nothing more to load!')),
                );
              } else {
                return SizedBox();
              }
            },
          );
        }
      },
    );
  }
}
