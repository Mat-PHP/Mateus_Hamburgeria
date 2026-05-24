/// Modelo de Hambúrguer - Programação Orientada a Objetos
/// Herança, encapsulamento e métodos
class Burger {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;

  Burger({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl = '',
    this.category = 'Tradicional',
    this.isAvailable = true,
  });

  /// Factory method - cria objeto a partir de JSON
  factory Burger.fromJson(Map<String, dynamic> json) {
    return Burger(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Sem nome',
      description: json['description'] ?? 'Sem descrição',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'Tradicional',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  /// Converte objeto para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
    };
  }

  /// Método para calcular preço com desconto
  double priceWithDiscount(double percent) {
    return price - (price * percent / 100);
  }

  @override
  String toString() => 'Burger(id: $id, name: $name, price: R\$ $price)';
}

/// Subclasse - Hambúrguer Promocional (herança)
class PromotionalBurger extends Burger {
  final double discountPercent;
  final DateTime validUntil;

  PromotionalBurger({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.imageUrl,
    super.category,
    required this.discountPercent,
    required this.validUntil,
  });

  double get discountedPrice => priceWithDiscount(discountPercent);

  bool get isValid => DateTime.now().isBefore(validUntil);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json.addAll({
      'discountPercent': discountPercent,
      'validUntil': validUntil.toIso8601String(),
      'discountedPrice': discountedPrice,
    });
    return json;
  }
}
