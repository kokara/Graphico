import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class VideoDetailScreen extends StatefulWidget {
  final VideoPlayerController _videoPlayerController;
  VideoDetailScreen(this._videoPlayerController);

  @override
  _VideoDetailScreenState createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  ChewieController _chewieController = ChewieController(
      videoPlayerController: VideoPlayerController.network(""));
  VideoPlayerController _videoPlayerController =
      VideoPlayerController.network("");
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    /*_chewieController = ChewieController(
      videoPlayerController: widget._videoPlayerController,
      aspectRatio: 5 / 8,
      autoInitialize: true,
      autoPlay: true,
      looping: true,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );*/
    initializeVideoPlayer().whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _chewieController.dispose();
    _videoPlayerController.dispose();
  }

  Future<void> initializeVideoPlayer() async {
    // await widget._videoPlayerController.initialize();

    _chewieController = ChewieController(
        videoPlayerController: widget._videoPlayerController,
        autoPlay: true,
        looping: false,
        materialProgressColors: ChewieProgressColors(
          bufferedColor: Colors.grey,
          backgroundColor: Colors.white,
          handleColor:
              Color.fromRGBO(47, 54, 64, 1), //Color.fromRGBO(47, 54, 64, 1),
          playedColor: Color.fromRGBO(47, 54, 64, 1),
        ),
        allowFullScreen: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      alignment: Alignment.topLeft,
      children: [
        _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).accentColor,
                ),
              )
            : Chewie(controller: _chewieController),
        Container(
          margin: EdgeInsets.only(top: 30, left: 4),
          child: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(
                Icons.clear_rounded,
                color: Theme.of(context).accentColor,
              )),
        ),
      ],
    ));
  }
}
