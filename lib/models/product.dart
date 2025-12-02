class Product {
  final String? id;
  final String? salonId;
  final String? title;
  final String? sku;
  final int? price;
  final int? quantity;
  final List<String> images;

  Product({
    required this.id,
    required this.salonId,
    required this.title,
    required this.sku,
    required this.price,
    required this.quantity,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    List<String> imgs = [];

    if (rawImages is List) {
      imgs = rawImages.map((e) => e.toString()).toList();
    }

    return Product(
      id: json['id'],
      salonId: json['salonId'],
      title: json['title'],
      sku: json['sku'],
      price: json['price'] is int
          ? json['price']
          : int.tryParse("${json['price']}"),
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse("${json['quantity']}"),
      images: imgs,
    );
  }
}
