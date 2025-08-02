class Video {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;
  final String publishedAt;
  final int size;

  Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    this.official = false,
    this.publishedAt = '',
    this.size = 720,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      site: json['site'] ?? '',
      type: json['type'] ?? '',
      official: json['official'] ?? false,
      publishedAt: json['published_at'] ?? '',
      size: json['size'] ?? 720,
    );
  }

  // YouTube URL getters
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
  String get youtubeThumbnail => 'https://img.youtube.com/vi/$key/hqdefault.jpg';
  String get youtubeEmbedUrl => 'https://www.youtube.com/embed/$key';

  // Helper getters
  bool get isYoutube => site.toLowerCase() == 'youtube';
  bool get isTrailer => type.toLowerCase() == 'trailer';
  bool get isTeaser => type.toLowerCase() == 'teaser';
  bool get isValidVideo => isYoutube && (isTrailer || isTeaser) && key.isNotEmpty;
}

class Review {
  final String id;
  final String author;
  final String content;
  final String createdAt;
  final String url;
  final double? rating;

  Review({
    required this.id,
    required this.author,
    required this.content,
    this.createdAt = '',
    this.url = '',
    this.rating,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      author: json['author'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'] ?? '',
      url: json['url'] ?? '',
      rating: json['author_details']?['rating']?.toDouble(),
    );
  }

  // Helper getters
  String get shortContent => content.length > 150
      ? '${content.substring(0, 150)}...'
      : content;

  bool get hasRating => rating != null;
  String get formattedRating => hasRating ? rating!.toStringAsFixed(1) : 'N/A';
}