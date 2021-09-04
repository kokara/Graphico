import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/image.dart' as myimg;
import '../provider/image_provider.dart' as img;
import '../widgets/error.dart';
import '../widgets/image_tile.dart';
import '../provider/notify_favourite.dart';

class ImageScreen extends StatefulWidget {
  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final scrollController = ScrollController();
  var user = FirebaseAuth.instance.currentUser;
  img.ImageProvider imageProvider = img.ImageProvider();
  void initState() {
    print('Hello');
    super.initState();
    if (user != null) {
      img.ImageProvider.getFavourites();
    }

    imageProvider.fetchCuratedPhotos();

    scrollController.addListener(() {
      if (scrollController.position.extentAfter < 2000) {
        imageProvider.fetchCuratedPhotos();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<NotifyFavourite>();

    print('in build');
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
        } else {
          return ListView.builder(
              controller: scrollController,
              itemCount: (snapshot.data?.length ?? 0) + 1,
              itemBuilder: (context, index) {
                if (index < (snapshot.data?.length ?? 0)) {
                  print(index);

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
                  /*Container(
                    width: double.infinity,
                    child: Image.network(snapshot.data?[index].src.large ??
                        "https://i.pinimg.com/600x315/14/f6/43/14f64328ffef40a0aa701f00779389d5.jpg"),
                  );*/
                } else if (!imageProvider.hasMore) {
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
