class Staff {
  final String? name;
  final String? email;

  Staff({
    this.name,
    this.email,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    final user = json["user"]; // CAN BE NULL

    return Staff(
      name: user?["name"],
      email: user?["email"],
    );
  }
}
