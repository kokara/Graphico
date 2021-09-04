import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import '../models/image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ImageProvider {
  List<Image> dataSoFar = [];
  static Map<int, bool> favourites = {};
  static Future<void> getFavourites() async {
    favourites = {};

    var user = FirebaseAuth.instance.currentUser;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('images')
          .doc(user!.uid)
          .collection('image')
          .get();
      for (int i = 0; i < querySnapshot.docs.length; i++) {
        var a = querySnapshot.docs[i];

        favourites[a['id']] = true;
      }
    } catch (e) {
      print(e);
    }
  }

  int totalResult = -1;
  StreamController<List<Image>> _controller = StreamController<List<Image>>();

  bool _isLoading = false;
  bool hasMore = true;
  int pageNo = -1;
  Stream<List<Image>> get stream => _controller.stream;
  Future<void> fetchCuratedPhotos() async {
    if (_isLoading || !hasMore) return Future.value();

    pageNo = (dataSoFar.length ~/ 10) + 1;
    print(pageNo);
    _isLoading = true;
    var response = await http.get(
        Uri.parse("https://api.pexels.com/v1/curated?page=$pageNo&per_page=10"),
        headers: {
          "Authorization":
              "563492ad6f91700001000001f48f2dea0c1248e19b8a8381cbcc0798"
        });
    print(response.statusCode);
    if (response.statusCode == 200) {
      _isLoading = false;
      final extractedData = json.decode(response.body);
      print(extractedData);
      totalResult = extractedData["total_results"];
      print(totalResult);

      extractedData['photos'].forEach((element) async {
        bool _isLike = false;

        Image image = Image(
          url: element["url"],
          id: element["id"],
          photographer: element["photographer"],
          like: _isLike,
          photographerUrl: element["photographer_url"],
          src: Sources(
            large: element["src"]["large"],
            medium: element["src"]["medium"],
            original: element["src"]["original"],
            small: element["src"]["small"],
          ),
        );
        dataSoFar.add(image);
      });
      _controller.add(dataSoFar);
      hasMore = dataSoFar.length < totalResult;
    } else {
      _controller.sink.addError("Something went wrong");
    }
  }

  Future<void> searchImage(String query) async {
    if (_isLoading || !hasMore) return Future.value();

    pageNo = (dataSoFar.length ~/ 10) + 1;
    print(pageNo);
    _isLoading = true;
    var response = await http.get(
        Uri.parse(
            "https://api.pexels.com/v1/search?query=$query&page=$pageNo&per_page=10"),
        headers: {
          "Authorization":
              "563492ad6f91700001000001f48f2dea0c1248e19b8a8381cbcc0798"
        });
    print(response.statusCode);
    if (response.statusCode == 200) {
      _isLoading = false;
      final extractedData = json.decode(response.body);
      print(extractedData);
      totalResult = extractedData["total_results"];
      print(totalResult);

      extractedData['photos'].forEach(
        (element) {
          Image image = Image(
            url: element["url"],
            id: element["id"],
            photographer: element["photographer"],
            photographerUrl: element["photographer_url"],
            src: Sources(
              large: element["src"]["large"],
              medium: element["src"]["medium"],
              original: element["src"]["original"],
              small: element["src"]["small"],
            ),
          );

          dataSoFar.add(image);
        },
      );
      _controller.add(dataSoFar);
      hasMore = dataSoFar.length < totalResult;
    } else {
      _controller.sink.addError("Something went wrong");
    }
  }
}
