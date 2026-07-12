sealed class Result<F, S> {
  const Result();

  T when<T>(T Function(F error) failure, T Function(S value) success) => switch (this) {
    Failure(:final error) => failure(error),
    Success(:final value) => success(value),
  };
}

class Success<F, S> extends Result<F, S> {
  const Success(this.value);

  final S value;
}

class Failure<F, S> extends Result<F, S> {
  const Failure(this.error);

  final F error;
}
