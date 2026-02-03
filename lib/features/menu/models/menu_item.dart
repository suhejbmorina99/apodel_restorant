class MenuItem {
  final String? id;
  final String restaurantId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final String category;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MenuItem({
    this.id,
    required this.restaurantId,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    this.isAvailable = true,
    this.createdAt,
    this.updatedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String?,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'is_available': isAvailable,
    };
  }

  MenuItem copyWith({
    String? id,
    String? restaurantId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    bool? isAvailable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
