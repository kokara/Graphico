import 'package:flutter/material.dart';
import 'package:graphico/screen/video_detail_screen.dart';
import 'package:video_player/video_player.dart';
import '../models/video.dart';
import 'package:dio/dio.dart';
import 'package:share/share.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:path_provider/path_provider.dart';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../provider/video_provider.dart';
import '../provider/notify_favourite.dart';
import 'package:provider/provider.dart';

class IconWidgetVideo extends StatefulWidget {
  Video _video;
  VideoPlayerController _videoPlayerController;
  bool _isFavourite;

  IconWidgetVideo(this._video, this._videoPlayerController, this._isFavourite);

  @override
  _IconWidgetVideoState createState() => _IconWidgetVideoState();
}

class _IconWidgetVideoState extends State<IconWidgetVideo> {
  String downloadLink = "";
  int selected = 0;
  bool _isSelected = false;
  Widget selectedSize(String size) {
    return Container(
      margin: EdgeInsets.only(right: 48),
      padding: EdgeInsets.only(bottom: 12, top: 12, left: 52),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
        color: Theme.of(context).primaryColorLight,
      ),
      width: double.infinity,
      child: Text(
        size,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget unSelectedSize(String size) {
    return Container(
      padding: EdgeInsets.only(bottom: 12, top: 12, left: 32),
      width: double.infinity,
      child: Text(
        size,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  Widget downloadButton() {
    return Container(
      margin: EdgeInsets.only(left: 164, top: 20),
      width: double.infinity,
      child: Material(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(50), bottomLeft: Radius.circular(50)),
        child: InkWell(
          child: Container(
            // width: double.infinity,
            padding: EdgeInsets.only(top: 12, bottom: 12),
            child: Text(
              "Download",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
          onTap: () {
            _isSelected = true;
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _saveVideo() async {
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path +
        "/" +
        widget._video.videoFile[selected].id.toString() +
        ".mp4";
    await Dio().download(widget._video.videoFile[selected].link, savePath,
        onReceiveProgress: (bytes, totalBytes) {
      var perc = (bytes / totalBytes) * 100;
      if (perc < 100)
        notification(perc.toInt(), widget._video.videoFile[selected].id,
            "downloading...");
      else
        notification(
            perc.toInt(), widget._video.videoFile[selected].id, "downloaded");
    });
    final result = await ImageGallerySaver.saveFile(savePath);
    print(result);
  }

  void notification(int bytes, int id, String body) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: id,
      channelKey: 'progress_bar',
      title: id.toString() + ".mp4",
      body: body,
      progress: bytes,
      notificationLayout: NotificationLayout.ProgressBar,
    ));
  }

  Future<void> modalBottomSheet(BuildContext context) async {
    selected = 0;

    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(6), topLeft: Radius.circular(6)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: 280,
              margin: EdgeInsets.only(top: 22, bottom: 20),
              child: Column(
                children: [
                  Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 1,
                              color: Theme.of(context).primaryColorLight),
                        ),
                      ),
                      height: 209,
                      child: ListView.builder(
                          itemCount: widget._video.videoFile.length,
                          itemBuilder: (ctx, i) {
                            final e = widget._video.videoFile[i];
                            if (selected == i) {
                              if (e.height != 1 && e.width != 1) {
                                return selectedSize(e.width.toString() +
                                    " x " +
                                    e.height.toString());
                              }
                              return selectedSize("hls");
                            }
                            return GestureDetector(
                                onTap: () {
                                  setModalState(() {
                                    selected = i;
                                  });
                                },
                                child: e.height != 1 && e.width != 1
                                    ? unSelectedSize(e.width.toString() +
                                        " x " +
                                        e.height.toString())
                                    : unSelectedSize("hls"));
                          })),
                  downloadButton()
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    widget._video.like = VideoProvider.favourites.containsKey(widget._video.id);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 4,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                widget._video.like = !widget._video.like;
              });
              var user = FirebaseAuth.instance.currentUser;
              if (widget._video.like) {
                List<dynamic> videoFile = [];
                for (int i = 0; i < widget._video.videoFile.length; i++) {
                  var e = widget._video.videoFile[i];
                  videoFile.add({
                    'id': e.id,
                    'height': e.height,
                    'width': e.width,
                    'link': e.link,
                  });
                }
                VideoProvider.favourites[widget._video.id] = true;
                FirebaseFirestore.instance
                    .collection('videos')
                    .doc(user!.uid)
                    .collection('video')
                    .doc(widget._video.id.toString())
                    .set({
                  'id': widget._video.id,
                  'url': widget._video.url,
                  'like': widget._video.like,
                  'photographer': widget._video.photographer,
                  'photographerUrl': widget._video.photographerUrl,
                  'videoUrl': widget._video.videoUrl,
                  'thumbnail': widget._video.thumbnail,
                  'videoFile': videoFile,
                });
              } else {
                if (widget._isFavourite) {
                  context.read<NotifyFavourite>().notify();
                }
                VideoProvider.favourites.remove(widget._video.id);
                FirebaseFirestore.instance
                    .collection('videos')
                    .doc(user!.uid)
                    .collection('video')
                    .doc(widget._video.id.toString())
                    .delete();
              }
            },
            icon: Icon(
              widget._video.like
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
            ),
            color: Theme.of(context).accentColor,
          ),
          IconButton(
            onPressed: () {
              Share.share(widget._video.videoUrl);
            },
            icon: Icon(
              Icons.share_rounded,
              color: Theme.of(context).accentColor,
            ),
          ),
          Expanded(
            child: Container(),
          ),
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          VideoDetailScreen(widget._videoPlayerController)),
                );
              },
              icon: Icon(
                Icons.fullscreen_rounded,
                color: Theme.of(context).accentColor,
              )),
          IconButton(
            onPressed: () async {
              await modalBottomSheet(context);
              if (_isSelected) {
                await _saveVideo();
              }
              selected = 0;
              _isSelected = false;
            },
            icon: Icon(
              Icons.download_rounded,
              color: Theme.of(context).accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
