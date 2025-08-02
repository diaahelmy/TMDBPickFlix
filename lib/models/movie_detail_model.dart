import 'video_result.dart'; // استيراد Video class

class MovieDetail {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final int? runtime;
  final String? tagline;
  final List<Genre> genres;
  final List<ProductionCompany> productionCompanies;
  final List<ProductionCountry> productionCountries;
  final List<SpokenLanguage> spokenLanguages;
  final List<Video> videos; // تغيير النوع إلى Video
  final List<Review> reviews;
  final int? budget;
  final int? revenue;
  final String status;
  final double popularity;
  final String? imdbId;
  final String? homepage;
  final bool adult;

  MovieDetail({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    this.runtime,
    this.tagline,
    required this.genres,
    required this.productionCompanies,
    required this.productionCountries,
    required this.spokenLanguages,
    required this.videos,
    required this.reviews,
    this.budget,
    this.revenue,
    required this.status,
    required this.popularity,
    this.imdbId,
    this.homepage,
    required this.adult,
  });

  factory MovieDetail.fromJson(Map<String, dynamic> json) {
    return MovieDetail(
      id: json['id'],
      title: json['title'] ?? json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? json['first_air_date'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      runtime: json['runtime'],
      tagline: json['tagline'],
      genres: (json['genres'] as List<dynamic>?)
          ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      productionCompanies: (json['production_companies'] as List<dynamic>?)
          ?.map((e) => ProductionCompany.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      productionCountries: (json['production_countries'] as List<dynamic>?)
          ?.map((e) => ProductionCountry.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      spokenLanguages: (json['spoken_languages'] as List<dynamic>?)
          ?.map((e) => SpokenLanguage.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      videos: (json['videos']?['results'] as List<dynamic>?)
          ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      reviews: (json['reviews']?['results'] as List<dynamic>?)
          ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      budget: json['budget'],
      revenue: json['revenue'],
      status: json['status'] ?? '',
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      imdbId: json['imdb_id'],
      homepage: json['homepage'],
      adult: json['adult'] ?? false,
    );
  }

  // Formatted getters
  String get formattedRuntime {
    if (runtime == null) return 'N/A';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }

  String get formattedBudget {
    if (budget == null || budget == 0) return 'N/A';
    if (budget! >= 1000000) {
      return '\$${(budget! / 1000000).toStringAsFixed(1)}M';
    }
    return '\$${budget!.toStringAsFixed(0)}';
  }

  String get formattedRevenue {
    if (revenue == null || revenue == 0) return 'N/A';
    if (revenue! >= 1000000) {
      return '\$${(revenue! / 1000000).toStringAsFixed(1)}M';
    }
    return '\$${revenue!.toStringAsFixed(0)}';
  }

  String get formattedVoteAverage => voteAverage.toStringAsFixed(1);

  // Video-related getters
  Video? get mainTrailer {
    final validVideos = videos.where((video) => video.isValidVideo).toList();
    if (validVideos.isEmpty) return null;

    // البحث عن تريلر رسمي أولاً
    final officialTrailers = validVideos.where((video) =>
    video.isTrailer && video.official
    ).toList();

    if (officialTrailers.isNotEmpty) {
      return officialTrailers.first;
    }

    // البحث عن أي تريلر
    final trailers = validVideos.where((video) => video.isTrailer).toList();
    if (trailers.isNotEmpty) {
      return trailers.first;
    }

    // إرجاع أول فيديو صالح
    return validVideos.first;
  }

  List<Video> get allTrailers {
    return videos.where((video) =>
    video.isValidVideo && (video.isTrailer || video.isTeaser)
    ).toList();
  }

  List<Video> get youtubeVideos {
    return videos.where((video) => video.isYoutube && video.key.isNotEmpty).toList();
  }

  bool get hasVideos => videos.isNotEmpty;
  bool get hasTrailers => allTrailers.isNotEmpty;
  bool get hasReviews => reviews.isNotEmpty;
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}

class ProductionCompany {
  final int id;
  final String name;
  final String? logoPath;
  final String originCountry;

  ProductionCompany({
    required this.id,
    required this.name,
    this.logoPath,
    required this.originCountry,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    return ProductionCompany(
      id: json['id'],
      name: json['name'] ?? '',
      logoPath: json['logo_path'],
      originCountry: json['origin_country'] ?? '',
    );
  }
}

class ProductionCountry {
  final String iso31661;
  final String name;

  ProductionCountry({required this.iso31661, required this.name});

  factory ProductionCountry.fromJson(Map<String, dynamic> json) {
    return ProductionCountry(
      iso31661: json['iso_3166_1'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class SpokenLanguage {
  final String englishName;
  final String iso6391;
  final String name;

  SpokenLanguage({
    required this.englishName,
    required this.iso6391,
    required this.name,
  });

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) {
    return SpokenLanguage(
      englishName: json['english_name'] ?? '',
      iso6391: json['iso_639_1'] ?? '',
      name: json['name'] ?? '',
    );
  }
}