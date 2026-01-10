class Service {
  final String id;
  final String title;
  final int durationMinutes;
  final String price;

  Service({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.price,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json["id"],
      title: json["title"],
      durationMinutes: json["durationMinutes"],
      price: json["price"],
    );
  }
}
