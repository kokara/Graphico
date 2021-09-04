class Image {
  int id;
  String url;
  Sources src;
  bool like;
  String photographer;
  String photographerUrl;
  Image({
    required this.id,
    required this.url,
    required this.src,
    this.like = false,
    required this.photographer,
    required this.photographerUrl,
  });
}

class Sources {
  String large;
  String original;
  String medium;
  String small;
  Sources({
    required this.large,
    required this.original,
    required this.medium,
    required this.small,
  });
}
