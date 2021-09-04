import 'package:flutter/material.dart';
import '../models/video.dart';
import 'upper_widget.dart';

import '../screen/video_detail_screen.dart';
import 'package:video_player/video_player.dart';
import './icon_widget_video.dart';

class VideoTile extends StatefulWidget {
  Video _video;
  bool _isFavoutite;
  VideoTile(this._video, this._isFavoutite);

  @override
  _VideoTileState createState() => _VideoTileState();
}

class _VideoTileState extends State<VideoTile> {
  VideoPlayerController _controller = VideoPlayerController.network(
      "https://player.vimeo.com/external/372074690.sd.mp4?s=4901b907e6de09403df67aa3f583757a8e5f5661&profile_id=164&oauth2_token_id=5744776");
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      widget._video.videoUrl,
    )..initialize().then((_) {
        setState(() {});
      });
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  bool _isPlaying = false;
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Column(
      children: [
        UpperWidget(
            photographerName: widget._video.photographer,
            photographerUrl: widget._video.photographerUrl,
            itemUrl: widget._video.url),
        GestureDetector(
          onTap: () {
            setState(() {
              _isPlaying = true;
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Container(
              height: 300,
              child: !_controller.value.isInitialized || !_isPlaying
                  ? Image.network(
                      widget._video.thumbnail,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )),
        ),
        IconWidgetVideo(widget._video, _controller, widget._isFavoutite),
        SizedBox(
          height: 10,
        ),
        Container(
          width: double.infinity,
          color: Colors.grey[200],
          height: 8,
        ),
      ],
    );
    ;
  }
}
