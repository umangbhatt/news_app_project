class Response<T> {
  Status status;
  T? data;
  String? message;

  Response.completed(this.data) : status = Status.success;
  Response.error(this.message) : status = Status.error;
  Response.loading() : status = Status.loading;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}

enum Status { success, error, loading }
