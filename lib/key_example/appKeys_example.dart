class AppKeys {
  static final String _basic = "your url API!";

  static Uri products(String? params, String? token) {
    if (params == null)
      return Uri.parse(
          _basic + "/products.json" + (token != null ? "?auth=$token" : ""));
    return Uri.parse(_basic +
        "/products/" +
        params +
        ".json" +
        (token != null ? "?auth=$token" : ""));
  }

  static Uri userFavorite({
    required String token,
    required String userId,
    required String productId,
  }) {
    return Uri.parse(
        "$_basic/userFavorite/$userId/$productId.json?auth=$token");
  }

  static Uri getFavorite({required String token, required String userId}) {
    return Uri.parse("$_basic/userFavorite/$userId.json?auth=$token");
  }

  static Uri orders(String? token, String? userId) {
    return Uri.parse(
        "$_basic/orders/$userId.json" + (token != null ? "?auth=$token" : ""));
  }

  static Uri singup() {
    return Uri.parse("your url singup");
  }

  static Uri singin() {
    return Uri.parse("your url singin");
  }
}
