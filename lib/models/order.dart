class OrderModel {
  final String id;
  final String salonId;
  final String salonName;
  final String title;
  final double price;
  final int quantity;
  final String status;
  final String image;

  OrderModel({
    required this.id,
    required this.salonId,
    required this.salonName,
    required this.title,
    required this.price,
    required this.quantity,
    required this.status,
    required this.image,
  });

  // ✅ COPY WITH
  OrderModel copyWith({
    String? status,
  }) {
    return OrderModel(
      id: id,
      salonId: salonId,
      salonName: salonName,
      title: title,
      price: price,
      quantity: quantity,
      status: status ?? this.status,
      image: image,
    );
  }
}
