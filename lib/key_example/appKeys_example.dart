class AppKeys {
  static final String _basic = "your url API!";

  static Uri products(String? params) {
    if (params == null) return Uri.parse(_basic + "/products.json");
    return Uri.parse(_basic + "/products/" + params + ".json");
  }

  static Uri orders(String? params) {
    if (params == null) return Uri.parse(_basic + "/orders.json");
    return Uri.parse(_basic + "/orders/" + params + ".json");
  }
}
