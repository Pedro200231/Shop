import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cart.dart';
import 'cart_item.dart';
import 'order.dart';
import 'product.dart';

class OrderList with ChangeNotifier {
  final List<Order> _items = [];

  List<Order> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  Future<void> addOrder(Cart cart) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders.json'),
      body: jsonEncode({
        'total': cart.totalAmount,
        'date': DateTime.now().toIso8601String(),
        'items': cart.items.values
            .map((cartItem) => {
                  'id': cartItem.id,
                  'productId': cartItem.productId,
                  'title': cartItem.name,
                  'quantity': cartItem.quantity,
                  'price': cartItem.price,
                })
            .toList(),
      }),
    );
  final id = jsonDecode(response.body)['name'];
  _items.insert(
    0,
    Order(
      id: id,
      total: cart.totalAmount,
      date: DateTime.now(),
      items: cart.items.values.toList(),
    ),
  );
  }

  Future<void> loadOrders() async {
    final response = await http.get(Uri.parse('$baseUrl/orders.json'));
    Map<String, dynamic> data = jsonDecode(response.body);
    _items.clear();
    data.forEach((orderId, orderData) {
      _items.add(
        Order(
          id: orderId,
          total: orderData['total'],
          date: DateTime.parse(orderData['date']),
          items: (orderData['items'] as List<dynamic>).map((item) {
            return CartItem(
              id: item['id'],
              productId: item['productId'],
              name: item['title'],
              quantity: item['quantity'],
              price: item['price'],
            );
          }).toList(),
        ),
      );
    });
    notifyListeners();
    }

}