sealed class Result<F, S> {
  const Result();
}

class Success<F, S> extends Result<F, S> {
  const Success(this.value);

  final S value;
}

class Failure<F, S> extends Result<F, S> {
  const Failure(this.error);

  final F error;
}
