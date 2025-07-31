// class MediaItem {
//   final int id;
//   final String title;
//   final String imagePath;
//   final String type; // movie, tv, person
//   final String? overview;
//   final double? voteAverage;
//
//   MediaItem({
//     required this.id,
//     required this.title,
//     required this.imagePath,
//     required this.type,
//     this.overview,
//     this.voteAverage,
//   });
//
//   factory MediaItem.fromJson(Map<String, dynamic> json) {
//     String type = json['media_type'] ?? 'movie';
//
//     return MediaItem(
//       id: json['id'],
//       title: json['title'] ?? json['name'] ?? '',
//       imagePath: json['poster_path'] ?? json['profile_path'] ?? '',
//       type: type,
//       overview: json['overview'],
//       voteAverage: json['vote_average'] != null
//           ? (json['vote_average'] as num).toDouble()
//           : null,
//     );
//   }
// }
