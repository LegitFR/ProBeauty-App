class Salon {
  final String id;
  final String name;
  final String address;
  final Geo? geo;
  final String? image;

  Salon({
    required this.id,
    required this.name,
    required this.address,
    this.geo,
    this.image,
  });

  factory Salon.fromJson(Map<String, dynamic> json) {
    return Salon(
      id: json["id"],
      name: json["name"],
      address: json["address"],
      geo: json["geo"] != null ? Geo.fromJson(json["geo"]) : null,
      image: json["image"],
    );
  }
}

class Geo {
  final double latitude;
  final double longitude;

  Geo({required this.latitude, required this.longitude});

  factory Geo.fromJson(Map<String, dynamic> json) {
    return Geo(
      latitude: (json["latitude"] as num).toDouble(),
      longitude: (json["longitude"] as num).toDouble(),
    );
  }
}
