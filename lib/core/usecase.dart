abstract interface class UseCaseWithParams<type, Params> {
  Future<Type> call(Params params);
}

abstract interface class UseCaseWithoutParams<type> {
  Future<Type> call();
}
