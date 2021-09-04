class Video {
  int id;
  String thumbnail;
  String url;
  String videoUrl;
  String photographer;
  String photographerUrl;
  bool like;
  List<VideoFile> videoFile;

  Video({
    required this.id,
    required this.thumbnail,
    required this.url,
    required this.videoUrl,
    required this.photographer,
    required this.photographerUrl,
    this.like = false,
    required this.videoFile,
  });
}

class VideoFile {
  int height;
  int width;
  String link;
  int id;
  VideoFile(
      {required this.height,
      required this.width,
      required this.link,
      required this.id});
}
