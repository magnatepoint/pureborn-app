class Vendor {
  final String id;
  final String name;
  final String? contact;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Vendor({
    required this.id,
    required this.name,
    this.contact,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['_id'],
      name: json['name'],
      contact: json['contact'],
      address: json['address'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'contact': contact, 'address': address};
  }
}
