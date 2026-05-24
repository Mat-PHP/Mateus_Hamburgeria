import 'dart:convert';

/// Modelo de Usuário - POO com encapsulamento
class User {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final DateTime? createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      address: json['address'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Converte para JSON string (usa dart:convert)
  String toJsonString() => json.encode(toJson());

  factory User.fromJsonString(String jsonString) {
    return User.fromJson(json.decode(jsonString));
  }
}

/// Modelo de Pedido - relacionamento com User
class Order {
  final int? id;
  final int userId;
  final List<Map<String, dynamic>> items;
  final double total;
  final String status;
  final DateTime createdAt;

  Order({
    this.id,
    required this.userId,
    required this.items,
    required this.total,
    this.status = 'pendente',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'] ?? 0,
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
      total: (json['total'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'pendente',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items,
      'total': total,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String toJsonString() => json.encode(toJson());
}
