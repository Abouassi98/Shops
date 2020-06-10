class Http_Exceptions implements Exception{
  final String message;
  Http_Exceptions({this.message});

  @override
  String toString() {
    return message;
    //return super.toString();
  }
}