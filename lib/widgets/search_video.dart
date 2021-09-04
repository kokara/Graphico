import 'package:flutter/material.dart';
import 'package:graphico/models/video.dart';
import '../provider/video_provider.dart';
import '../widgets/error.dart';
import '../widgets/video_tile.dart';
import '../models/hide_nav_bar.dart';
import '../provider/notify_favourite.dart';
import 'package:provider/provider.dart';

class SearchVideo extends StatefulWidget {
  String _query;
  Key key;
  HideNavbar _hiding;
  SearchVideo(this._query, this.key, this._hiding);

  @override
  _SearchVideoState createState() => _SearchVideoState();
}

class _SearchVideoState extends State<SearchVideo> {
  VideoProvider videoProvider = VideoProvider();

  @override
  void initState() {
    super.initState();

    videoProvider.searchVideo(widget._query);
    print('Hii');
    widget._hiding.controller.addListener(() {
      if (widget._hiding.controller.position.extentAfter < 2000) {
        videoProvider.searchVideo(widget._query);
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
        } else if (videoProvider.totalResult == 0) {
          return Center(
            child: Text(
              'Result not found!',
              style: TextStyle(
                  fontSize: 18, color: Color.fromRGBO(131, 149, 167, 1)),
            ),
          );
        } else {
          return ListView.builder(
            controller: widget._hiding.controller,
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
                                    "https://player.vimeo.com/external/342571552.hd.mp4?s=6aa6f164de3812abadff3dde86d19f7a074a8a66&profile_id=175&oauth2_token_id=57447761"),
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
