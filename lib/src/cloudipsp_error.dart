class CloudipspError extends Error {
  String? message;

  CloudipspError(this.message);
}

class CloudipspUserError extends CloudipspError {
  String code;

  CloudipspUserError(this.code, String? message) : super(message);
}

class CloudipspApiError extends CloudipspError {
  int? code;
  String? requestId;

  CloudipspApiError(this.code, this.requestId, String? message)
      : super(message);
}
