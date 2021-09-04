import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './image_screen.dart';
import './video_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isImage = true;

  void selectedItem(BuildContext ctx, item) {
    if (item == 0) {
      if (_isImage) return;

      setState(() {
        _isImage = true;
      });
    } else {
      if (!_isImage) return;

      setState(() {
        _isImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Graphico',
        ),
        elevation: 0,
        actions: [
          _isImage
              ? Icon(
                  Icons.image_rounded,
                )
              : Icon(
                  Icons.videocam_rounded,
                ),
          PopupMenuButton(
              icon: Icon(Icons.keyboard_arrow_down_rounded),
              onSelected: (item) => selectedItem(context, item),
              itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 0,
                      child: Row(
                        children: [
                          Icon(
                            Icons.image_rounded,
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
                            Icons.videocam_rounded,
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
                    )
                  ]),
        ],
      ),
      body: IndexedStack(
        index: _isImage ? 0 : 1,
        children: [ImageScreen(), VideoScreen()],
      ),
    );
  }
}
