class RestaurantInfo {
  const RestaurantInfo({
    required this.name,
    required this.address,
    required this.workingHours,
    required this.phone,
  });

  final String name;
  final String address;
  final String workingHours;
  final String phone;

  RestaurantInfo copyWith({
    String? name,
    String? address,
    String? workingHours,
    String? phone,
  }) {
    return RestaurantInfo(
      name: name ?? this.name,
      address: address ?? this.address,
      workingHours: workingHours ?? this.workingHours,
      phone: phone ?? this.phone,
    );
  }

  factory RestaurantInfo.fromJson(Map<String, dynamic> json) {
    return RestaurantInfo(
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      workingHours:
          json['workingHours'] as String? ?? json['hours'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'workingHours': workingHours,
      'phone': phone,
    };
  }

  static const empty = RestaurantInfo(
    name: '',
    address: '',
    workingHours: '',
    phone: '',
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is RestaurantInfo &&
        other.name == name &&
        other.address == address &&
        other.workingHours == workingHours &&
        other.phone == phone;
  }

  @override
  int get hashCode => Object.hash(name, address, workingHours, phone);
}
