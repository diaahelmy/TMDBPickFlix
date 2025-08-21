class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final double voteAverage;
  final String type; // "movie" أو "tv"

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.voteAverage,
    required this.type,

  });

  factory Movie.fromJson(Map<String, dynamic> json, {String? type}) {
    // إذا جاي من TMDB، نقدر نحدد النوع تلقائيًا
    final detectedType = type ?? (json.containsKey('title') ? "movie" : "tv");

    return Movie(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      type: detectedType,
    );
  }
}

