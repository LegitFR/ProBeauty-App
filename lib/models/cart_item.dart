class CartItemModel {
  final String id;
  final String productId;
  final String title;
  final double price;
  final int quantity;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.quantity,
  });
}
