typedef FutureResult<L, R> = Future<Result<L, R>>;

abstract class Result<L, R> {
  const Result(this.value);

  final dynamic value;

  void fold({
    required void Function(L value) onLeft,
    required void Function(R value) onRight,
  }) {
    if (value is L) {
      onLeft(value as L);
      return;
    }
    onRight(value as R);
  }
}

class Left<L, R> extends Result<L, R> {
  const Left(L super.value);
}

class Right<L, R> extends Result<L, R> {
  const Right(R super.value);
}
