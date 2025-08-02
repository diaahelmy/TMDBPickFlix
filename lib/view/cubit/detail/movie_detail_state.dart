import 'package:equatable/equatable.dart';
import '../../../models/movie_detail_model.dart';

sealed class MovieDetailState extends Equatable {
  const MovieDetailState();

  @override
  List<Object?> get props => [];
}

final class MovieDetailInitial extends MovieDetailState {
  const MovieDetailInitial();
}

final class MovieDetailLoading extends MovieDetailState {
  const MovieDetailLoading();
}

final class MovieDetailLoaded extends MovieDetailState {
  final MovieDetail movieDetail;

  const MovieDetailLoaded(this.movieDetail);

  @override
  List<Object?> get props => [movieDetail];
}

final class MovieDetailError extends MovieDetailState {
  final String message;

  const MovieDetailError(this.message);

  @override
  List<Object?> get props => [message];
}