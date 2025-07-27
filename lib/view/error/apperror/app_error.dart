import 'package:equatable/equatable.dart';

abstract class AppError extends Equatable {
  final String message;
  final String? code;
  final bool isRetryable;

  const AppError({
    required this.message,
    this.code,
    this.isRetryable = true,
  });

  @override
  List<Object?> get props => [message, code, isRetryable];
}

class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.code,
    super.isRetryable = true,
  });
}

class DataError extends AppError {
  const DataError({
    required super.message,
    super.code,
    super.isRetryable = false,
  });
}