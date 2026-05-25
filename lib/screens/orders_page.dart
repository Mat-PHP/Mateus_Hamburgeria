// lib/models/order_model.dart
class Order {
  final int? id;
  final String formaPagamento;
  final String data;
  final double total;

  Order({this.id, required this.formaPagamento, required this.data, required this.total});

  Map<String, dynamic> toJson() => {
    "forma_pagamento": formaPagamento,
    "data": data,
    "total": total,
  };
  // ... factory fromJson...
}