class MediaItem {
  final String url;
  final MediaType type;

  MediaItem({required this.url, required this.type});
}

enum MediaType { image, video }