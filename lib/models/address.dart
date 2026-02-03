class AddressModel {
  final String id;
  final String fullName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String addressType;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.addressType,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json["id"],
      fullName: json["fullName"],
      phone: json["phone"],
      addressLine1: json["addressLine1"],
      addressLine2: json["addressLine2"],
      city: json["city"],
      state: json["state"],
      postalCode: json["postalCode"],
      country: json["country"],
      addressType: json["addressType"] ?? "Home",
      isDefault: json["isDefault"] ?? false,
    );
  }

  String get shortAddress {
    return "$addressLine1, $city, $state - $postalCode";
  }
}
