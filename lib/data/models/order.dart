enum DeliveryMode { pickup, delivery }

enum OrderStatus { pending, accepted, cooking, delivering, completed, cancelled }

enum PaymentMethod { cash, cardCourier, cardOnline }

class OrderItem {
  final String dishId;
  final String dishName;
  final double dishPrice;
  final int quantity;

  const OrderItem({
    required this.dishId,
    required this.dishName,
    required this.dishPrice,
    required this.quantity,
  });

  double get total => dishPrice * quantity;

  OrderItem copyWith({int? quantity}) {
    return OrderItem(
      dishId: dishId,
      dishName: dishName,
      dishPrice: dishPrice,
      quantity: quantity ?? this.quantity,
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      dishId: json['dishId'] as String,
      dishName: json['dishName'] as String,
      dishPrice: (json['dishPrice'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dishId': dishId,
      'dishName': dishName,
      'dishPrice': dishPrice,
      'quantity': quantity,
    };
  }
}

class UserProfile {
  final String fullName;
  final String phone;
  final List<String> addresses;
  final int utensilsCount;
  final List<String> recentOrderIds;

  const UserProfile({
    required this.fullName,
    required this.phone,
    this.addresses = const [],
    this.utensilsCount = 0,
    this.recentOrderIds = const [],
  });

  String get defaultAddress => addresses.isNotEmpty ? addresses.first : '';

  UserProfile copyWith({
    String? fullName,
    String? phone,
    String? defaultAddress,
    List<String>? addresses,
    int? utensilsCount,
    List<String>? recentOrderIds,
  }) {
    final resolvedAddresses = addresses ?? () {
      if (defaultAddress == null) {
        return this.addresses;
      }
      if (defaultAddress.isEmpty) {
        return this.addresses.skip(1).toList();
      }
      if (this.addresses.isEmpty) {
        return [defaultAddress];
      }
      return [defaultAddress, ...this.addresses.skip(1)];
    }();
    final resolvedOrderIds = recentOrderIds ?? this.recentOrderIds;
    return UserProfile(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      addresses: List<String>.from(resolvedAddresses),
      utensilsCount: utensilsCount ?? this.utensilsCount,
      recentOrderIds: List<String>.from(resolvedOrderIds),
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final addresses = (json['addresses'] as List<dynamic>?)
            ?.map((value) => value as String)
            .toList() ??
        <String>[];
    if (addresses.isEmpty) {
      final legacyAddress = json['defaultAddress'] as String?;
      if (legacyAddress != null && legacyAddress.isNotEmpty) {
        addresses.add(legacyAddress);
      }
    }
    final orderIds = (json['recentOrderIds'] as List<dynamic>?)
            ?.map((value) => value as String)
            .toList() ??
        <String>[];
    return UserProfile(
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      addresses: addresses,
      utensilsCount: json['utensilsCount'] as int? ?? 0,
      recentOrderIds: orderIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'addresses': addresses,
      'defaultAddress': defaultAddress,
      'utensilsCount': utensilsCount,
      'recentOrderIds': recentOrderIds,
    };
  }
}

class Order {
  final String id;
  final DeliveryMode mode;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final List<OrderItem> items;
  final DateTime createdAt;
  final String customerName;
  final String phone;
  final String address;
  final int utensilsCount;
  final String? deliveryInterval;
  final String? cancellationReason;

  const Order({
    required this.id,
    required this.mode,
    required this.status,
    required this.paymentMethod,
    required this.items,
    required this.createdAt,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.utensilsCount,
    this.deliveryInterval,
    this.cancellationReason,
  });

  double get total => items.fold(0, (sum, item) => sum + item.total);

  Order copyWith({
    DeliveryMode? mode,
    OrderStatus? status,
    PaymentMethod? paymentMethod,
    List<OrderItem>? items,
    DateTime? createdAt,
    String? customerName,
    String? phone,
    String? address,
    int? utensilsCount,
    String? deliveryInterval,
    String? cancellationReason,
  }) {
    return Order(
      id: id,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      utensilsCount: utensilsCount ?? this.utensilsCount,
      deliveryInterval: deliveryInterval ?? this.deliveryInterval,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      mode: DeliveryMode.values.firstWhere(
        (element) => element.name == (json['mode'] as String? ?? 'pickup'),
        orElse: () => DeliveryMode.pickup,
      ),
      status: OrderStatus.values.firstWhere(
        (element) => element.name == (json['status'] as String? ?? 'pending'),
        orElse: () => OrderStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (element) => element.name == (json['paymentMethod'] as String? ?? 'cash'),
        orElse: () => PaymentMethod.cash,
      ),
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      customerName: json['customerName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      utensilsCount: json['utensilsCount'] as int? ?? 0,
      deliveryInterval: json['deliveryInterval'] as String?,
      cancellationReason: json['cancellationReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mode': mode.name,
      'status': status.name,
      'paymentMethod': paymentMethod.name,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'utensilsCount': utensilsCount,
      'deliveryInterval': deliveryInterval,
      'cancellationReason': cancellationReason,
    };
  }
}
