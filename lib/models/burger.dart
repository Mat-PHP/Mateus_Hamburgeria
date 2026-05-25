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

  factory Burger.fromJson(Map<String, dynamic> json) {
    return Burger(
      // Evita o erro convertendo para int de forma segura
      id: json['id'] is int 
          ? json['id'] 
          : int.parse(json['id'].toString()),
          
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      
      // Evita erros se o preço vier como int ou String
      price: json['price'] is num 
          ? (json['price'] as num).toDouble() 
          : double.parse((json['price'] ?? 0).toString()),
          
      category: json['category'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

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
