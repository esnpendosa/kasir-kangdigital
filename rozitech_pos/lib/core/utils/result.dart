/// Represents the result of a network or repository call.
/// Avoids throwing exceptions across layers; use fold/when instead.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;

  /// Execute [onSuccess] or [onFailure] based on outcome.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, Object? error) onFailure,
  }) {
    return switch (this) {
      Success<T> s => onSuccess(s.data),
      Failure<T> f => onFailure(f.message, f.error),
    };
  }
}

/// Successful result carrying data [T].
final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

/// Failed result with a human-readable message and optional raw error.
final class Failure<T> extends Result<T> {
  const Failure(this.message, [this.error]);
  final String message;
  final Object? error;
}
