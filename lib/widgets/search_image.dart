import 'package:flutter/material.dart';
import '../models/image.dart' as myimg;
import '../provider/image_provider.dart' as img;
import '../widgets/error.dart';
import '../widgets/image_tile.dart';
import '../models/hide_nav_bar.dart';
import '../provider/notify_favourite.dart';
import 'package:provider/provider.dart';

class SearchImage extends StatefulWidget {
  String _query;
  HideNavbar _hiding;
  Key key;
  SearchImage(this._query, this.key, this._hiding);

  @override
  _SearchImageState createState() => _SearchImageState();
}

class _SearchImageState extends State<SearchImage> {
  // final scrollController = ScrollController();
  img.ImageProvider imageProvider = img.ImageProvider();
  void initState() {
    print('Hello');
    super.initState();
    imageProvider.searchImage(widget._query);

    widget._hiding.controller.addListener(() {
      if (widget._hiding.controller.position.extentAfter < 2000) {
        imageProvider.fetchCuratedPhotos();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<NotifyFavourite>();
    return StreamBuilder(
      stream: imageProvider.stream,
      builder: (context, AsyncSnapshot<List<myimg.Image>> snapshot) {
        if (snapshot.hasError)
          return Error();
        else if (!snapshot.hasData) {
          return Center(
              child: CircularProgressIndicator(
            color: Theme.of(context).accentColor,
          ));
        } else if (imageProvider.totalResult == 0)
          return Center(
            child: Text(
              'Result not found!',
              style: TextStyle(
                  fontSize: 18, color: Color.fromRGBO(131, 149, 167, 1)),
            ),
          );
        else {
          return ListView.builder(
              controller: widget._hiding.controller,
              itemCount: (snapshot.data?.length ?? 0) + 1,
              itemBuilder: (context, index) {
                if (index < (snapshot.data?.length ?? 0)) {
                  return ImageTile(
                      snapshot.data?[index] ??
                          myimg.Image(
                              id: 1,
                              url:
                                  "https://i.pinimg.com/600x315/14/f6/43/14f64328ffef40a0aa701f00779389d5.jpg",
                              photographer: "abcd",
                              photographerUrl:
                                  "https://www.pexels.com/@drdeden88",
                              src: myimg.Sources(
                                  large:
                                      "https://i.pinimg.com/600x315/14/f6/43/14f64328ffef40a0aa701f00779389d5.jpg",
                                  medium:
                                      "https://i.pinimg.com/600x315/14/f6/43/14f64328ffef40a0aa701f00779389d5.jpg",
                                  small:
                                      "https://i.pinimg.com/600x315/14/f6/43/14f64328ffef40a0aa701f00779389d5.jpg",
                                  original:
                                      "https://i.pinimg.com/600x315/14/f6/43/14f64328ffef40a0aa701f00779389d5.jpg")),
                      false);
                } else if (!imageProvider.hasMore) {
                  print("akdksmkl");
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: Text('Nothing more to load!')),
                  );
                } else {
                  return SizedBox();
                }
              });
        }
      },
    );
  }
}
