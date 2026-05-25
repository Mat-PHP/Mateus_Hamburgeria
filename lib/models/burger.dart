class Burger {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool isAvailable;
  final String imageUrl;

  Burger({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.isAvailable,
    required this.imageUrl,
  });

  // Converte de JSON para o Objeto Burger (Usado no GET)
  factory Burger.fromJson(Map<String, dynamic> json) {
    return Burger(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      category: json['category'],
      isAvailable: json['isAvailable'],
      imageUrl: json['imageUrl'],
    );
  }

  // Converte o Objeto Burger para JSON (Usado no POST e PUT)
  // ESTE É O MÉTODO QUE ESTAVA FALTANDO
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
    };
  }
}