class MenuModel {
  final int? id; 
  final String name;
  final int price;
  final int stock;
  final String? image;

  MenuModel({
    this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.image,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      stock: json['stock'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
    };
  }
}