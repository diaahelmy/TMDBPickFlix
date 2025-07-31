// enum MediaType { movie, tv, person }
//
// class SearchResult {
//   final int id;
//   final String name;
//   final String? posterPath;
//   final MediaType mediaType;
//   final double voteAverage;
//   SearchResult({
//     required this.id,
//     required this.name,
//     required this.posterPath,
//     required this.mediaType,
//     required this.voteAverage,
//
//   });
//
//   factory SearchResult.fromJson(Map<String, dynamic> json) {
//     final typeString = json['media_type'];
//     late MediaType mediaType;
//     if (typeString == 'movie') {
//       mediaType = MediaType.movie;
//     } else if (typeString == 'tv') {
//       mediaType = MediaType.tv;
//     } else {
//       mediaType = MediaType.person;
//     }
//
//     return SearchResult(
//       id: json['id'],
//       name: json['title'] ?? json['name'] ?? '',
//       posterPath: json['poster_path'] ?? json['profile_path'],
//       mediaType: mediaType,
//       voteAverage: (json['vote_average'] as num).toDouble(),
//     );
//   }
// }
