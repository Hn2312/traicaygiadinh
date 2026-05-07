class Fruit {
  final String id;
  final String name;
  final int price;
  final String unit;
  final String? imageUrl; // ← Thêm trường này
  final String description;
  final String origin;

  Fruit({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    this.imageUrl,
    required this.description,
    required this.origin,
  });

  factory Fruit.fromJson(Map<String, dynamic> json) {
    return Fruit(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      unit: json['unit'],
      imageUrl: json['image_url'],
      description: json['description'] ?? '',
      origin: json['origin'] ?? '',
    );
  }
}
