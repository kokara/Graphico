import 'package:flutter/material.dart';
import '../models/image.dart' as img;
import './icon_widget.dart';

import './upper_widget.dart';

class ImageTile extends StatelessWidget {
  final img.Image image;
  final _isFavourite;

  ImageTile(this.image, this._isFavourite);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UpperWidget(
            photographerName: image.photographer,
            photographerUrl: image.photographerUrl,
            itemUrl: image.url),
        Container(
          child: Image.network(
            image.src.large,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        IconWidget(image, _isFavourite),
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
  }
}
