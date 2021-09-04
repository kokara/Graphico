import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/video.dart';

class VideoProvider {
  List<Video> dataSoFar = [];
  static Map<int, bool> favourites = {};
  static Future<void> getFavourites() async {
    favourites = {};

    var user = FirebaseAuth.instance.currentUser;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('videos')
          .doc(user!.uid)
          .collection('video')
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
  StreamController<List<Video>> _controller = StreamController<List<Video>>();
  bool _isLoading = false;
  bool hasMore = true;
  int pageNo = -1;
  Stream<List<Video>> get stream => _controller.stream;

  Future<void> fetchCuratedVideos() async {
    if (_isLoading || !hasMore) return Future.value();
    pageNo = (dataSoFar.length ~/ 20) + 1;
    print(pageNo);
    _isLoading = true;
    var response = await http.get(
        Uri.parse(
            "https://api.pexels.com/videos/popular?page=$pageNo&per_page=20"),
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

      extractedData["videos"].forEach(
        (element) {
          String videoUrl = element["video_files"][0]["link"];
          List<VideoFile> videoFile = [];

          for (int i = 0; i < element["video_files"].length; i++) {
            if (element["video_files"][i]["quality"] != "hls" &&
                element["video_files"][i]["width"] <= 1080 &&
                element["video_files"][i]["height"] <= 1920) {
              videoFile.add(
                VideoFile(
                    height: element["video_files"][i]["height"] ?? 1,
                    width: element["video_files"][i]["width"] ?? 1,
                    link: element["video_files"][i]["link"],
                    id: element["video_files"][i]["id"]),
              );
            }
            if (element["video_files"][i]["quality"] == "sd") {
              videoUrl = element["video_files"][i]["link"];
            }
          }
          print(videoUrl);
          Video video = Video(
              id: element["id"],
              thumbnail: element["video_pictures"][0]["picture"],
              url: element["url"],
              videoUrl: videoUrl,
              photographer: element["user"]["name"],
              photographerUrl: element["user"]["url"],
              videoFile: videoFile);
          dataSoFar.add(video);
        },
      );
      _controller.add(dataSoFar);
      hasMore = dataSoFar.length < totalResult;
    } else {
      _controller.sink.addError("Something went wrong");
    }
  }

  Future<void> searchVideo(String query) async {
    if (_isLoading || !hasMore) return Future.value();
    pageNo = (dataSoFar.length ~/ 20) + 1;
    print(pageNo);
    _isLoading = true;
    var response = await http.get(
        Uri.parse(
            "https://api.pexels.com/videos/search?query=$query&page=$pageNo&per_page=20"),
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

      extractedData["videos"].forEach(
        (element) {
          String videoUrl = element["video_files"][0]["link"];
          List<VideoFile> videoFile = [];

          for (int i = 0; i < element["video_files"].length; i++) {
            if (element["video_files"][i]["quality"] != "hls" &&
                element["video_files"][i]["width"] <= 1080 &&
                element["video_files"][i]["height"] <= 1920) {
              videoFile.add(
                VideoFile(
                    height: element["video_files"][i]["height"] ?? 1,
                    width: element["video_files"][i]["width"] ?? 1,
                    link: element["video_files"][i]["link"],
                    id: element["video_files"][i]["id"]),
              );
            }
            if (element["video_files"][i]["quality"] == "sd") {
              videoUrl = element["video_files"][i]["link"];
            }
          }
          print(videoUrl);
          Video video = Video(
              id: element["id"],
              thumbnail: element["video_pictures"][0]["picture"],
              url: element["url"],
              videoUrl: videoUrl,
              photographer: element["user"]["name"],
              photographerUrl: element["user"]["url"],
              videoFile: videoFile);
          dataSoFar.add(video);
        },
      );
      _controller.add(dataSoFar);
      hasMore = dataSoFar.length < totalResult;
    } else {
      _controller.sink.addError("Something went wrong");
    }
  }
}
