import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/exceptions/http_exception.dart';
import 'package:shop_app/key/appKeys.dart';
import 'package:shop_app/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];
  String? _token;
  String? _userId;

  Products([this._token, this._items = const [], this._userId]);

  List<Product> get allItems => [..._items];

  int get itemsCount {
    return _items.length;
  }

  List<Product> get favoriteItems =>
      _items.where((prod) => prod.isFavorite).toList();

  Future<void> addProduct(Product newProduct) async {
    final response = await http.post(
      AppKeys.products(null, _token),
      body: json.encode(
        {
          'title': newProduct.title,
          'price': newProduct.price,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'isFavorite': newProduct.isFavorite,
        },
      ),
    );

    _items.add(
      Product(
        id: json.decode(response.body)['name'],
        title: newProduct.title,
        description: newProduct.description,
        price: newProduct.price,
        imageUrl: newProduct.imageUrl,
      ),
    );
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    if (product.id == "") return;

    final index = _items.indexWhere((prod) => prod.id == product.id);
    if (index == -1) return;

    await http.patch(
      AppKeys.products(product.id, _token),
      body: json.encode(
        {
          'title': product.title,
          'price': product.price,
          'description': product.description,
          'imageUrl': product.imageUrl,
        },
      ),
    );
    _items[index] = product;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final index = _items.indexWhere((prod) => prod.id == id);
    if (index == -1) return;

    final product = _items[index];
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();

    final response = await http.delete(AppKeys.products(id, _token));
    if (response.statusCode >= 400) {
      _items.insert(index, product);
      notifyListeners();
      throw HttpException('Ocorreu um erro na exclusão do produto!');
    }
  }

  Future<void> loadingProducts() async {
    final response = await http.get(AppKeys.products(null, _token));

    _items.clear();
    if (response.statusCode < 300) {
      Map<String, dynamic>? _data = json.decode(response.body);
      final favResponse =
          await http.get(AppKeys.getFavorite(token: _token!, userId: _userId!));
      final favMap = json.decode(favResponse.body);

      if (_data != null) {
        _data.forEach((productId, productData) {
          final bool isFavorite =
              favMap == null ? false : favMap[productId] ?? false;
          _items.add(
            Product(
              id: productId,
              title: productData['title'],
              description: productData['description'],
              price: productData['price'],
              imageUrl: productData['imageUrl'],
              isFavorite: isFavorite,
            ),
          );
        });
        notifyListeners();
      }
    }
    return Future.value();
  }
}
