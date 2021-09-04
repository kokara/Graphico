import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:share/share.dart';
import '../models/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../provider/image_provider.dart' as myimg;
import '../provider/notify_favourite.dart';
import 'package:provider/provider.dart';

class IconWidget extends StatefulWidget {
  img.Image _image;
  bool _isFavourite;

  IconWidget(this._image, this._isFavourite);
  @override
  _IconWidgetState createState() => _IconWidgetState();
}

class _IconWidgetState extends State<IconWidget> {
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
      margin: EdgeInsets.only(left: 164),
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

  void notification(int bytes, int id, String body) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: id + selected,
      channelKey: 'progress_bar',
      title: id.toString() + selected.toString() + ".jpeg",
      body: body,
      progress: bytes,
      notificationLayout: NotificationLayout.ProgressBar,
    ));
  }

  Future<void> download() async {
    var response = await Dio().get(downloadLink,
        options: Options(
          responseType: ResponseType.bytes,
        ), onReceiveProgress: (bytes, totalBytes) {
      var perc = (bytes / totalBytes) * 100;
      if (perc < 100)
        notification(perc.toInt(), widget._image.id, "downloading...");
      else
        notification(perc.toInt(), widget._image.id, "downloaded");
    });
    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(response.data),
      name: widget._image.id.toString() + selected.toString(),
    );

    print(result);
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
              margin: EdgeInsets.only(top: 22, bottom: 18),
              child: Column(
                children: [
                  if (selected == 0)
                    selectedSize("Original")
                  else
                    GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selected = 0;
                          });
                        },
                        child: unSelectedSize("Original")),
                  if (selected == 1)
                    selectedSize("Large")
                  else
                    GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selected = 1;
                          });
                        },
                        child: unSelectedSize("Large")),
                  if (selected == 2)
                    selectedSize("Medium")
                  else
                    GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selected = 2;
                          });
                        },
                        child: unSelectedSize("Medium")),
                  if (selected == 3)
                    selectedSize("Small")
                  else
                    GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selected = 3;
                          });
                        },
                        child: unSelectedSize("Small")),
                  SizedBox(
                    height: 24,
                  ),
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
    widget._image.like =
        myimg.ImageProvider.favourites.containsKey(widget._image.id);

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
                widget._image.like = !widget._image.like;
              });
              var user = FirebaseAuth.instance.currentUser;
              if (widget._image.like) {
                myimg.ImageProvider.favourites[widget._image.id] = true;
                FirebaseFirestore.instance
                    .collection('images')
                    .doc(user!.uid)
                    .collection('image')
                    .doc(widget._image.id.toString())
                    .set({
                  'id': widget._image.id,
                  'url': widget._image.url,
                  'like': widget._image.like,
                  'photographer': widget._image.photographer,
                  'photographerUrl': widget._image.photographerUrl,
                  'large': widget._image.src.large,
                  'original': widget._image.src.original,
                  'medium': widget._image.src.medium,
                  'small': widget._image.src.small
                });
              } else {
                if (widget._isFavourite) {
                  context.read<NotifyFavourite>().notify();
                }
                myimg.ImageProvider.favourites.remove(widget._image.id);
                FirebaseFirestore.instance
                    .collection('images')
                    .doc(user!.uid)
                    .collection('image')
                    .doc(widget._image.id.toString())
                    .delete();
              }
            },
            icon: Icon(
              widget._image.like
                  ? Icons.favorite_rounded
                  : Icons.favorite_outline_rounded,
            ),
            color: Theme.of(context).accentColor,
          ),
          IconButton(
            onPressed: () {
              Share.share(widget._image.src.original);
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
            onPressed: () async {
              await modalBottomSheet(context);
              if (_isSelected) {
                if (selected == 0)
                  downloadLink = widget._image.src.original;
                else if (selected == 1)
                  downloadLink = widget._image.src.large;
                else if (selected == 2)
                  downloadLink = widget._image.src.medium;
                else
                  downloadLink = widget._image.src.small;
                await download();
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
