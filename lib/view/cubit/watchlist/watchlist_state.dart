import 'package:equatable/equatable.dart';
import '../../../models/movie_model.dart';

abstract class WatchlistState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WatchlistInitial extends WatchlistState {}

class WatchlistLoading extends WatchlistState {}

class WatchlistLoaded extends WatchlistState {
  final List<Movie> watchlist;
  WatchlistLoaded(this.watchlist);

  @override
  List<Object?> get props => [watchlist];
}

class WatchlistError extends WatchlistState {
  final String message;
  WatchlistError(this.message);

  @override
  List<Object?> get props => [message];
}
