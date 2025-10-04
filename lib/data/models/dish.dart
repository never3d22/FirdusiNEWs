class Dish {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final double price;
  final int weight;
  final String imageUrl;
  final bool isHidden;

  const Dish({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.price,
    required this.weight,
    required this.imageUrl,
    this.isHidden = false,
  });

  Dish copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    double? price,
    int? weight,
    String? imageUrl,
    bool? isHidden,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      weight: weight ?? this.weight,
      imageUrl: imageUrl ?? this.imageUrl,
      isHidden: isHidden ?? this.isHidden,
    );
  }

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      categoryId: json['categoryId'] as String,
      price: (json['price'] as num).toDouble(),
      weight: json['weight'] as int,
      imageUrl: json['imageUrl'] as String,
      isHidden: json['isHidden'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'price': price,
      'weight': weight,
      'imageUrl': imageUrl,
      'isHidden': isHidden,
    };
  }
}
