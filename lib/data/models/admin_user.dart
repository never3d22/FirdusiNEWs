import 'order.dart';

class AdminUser {
  AdminUser({
    required this.phone,
    required this.profile,
    required List<Order> orders,
    required this.isBlocked,
    this.isActive = false,
  }) : orders = List<Order>.unmodifiable(orders);

  /// Normalized phone number or generated identifier for guest checkouts.
  final String phone;

  /// Profile information associated with the user.
  final UserProfile profile;

  /// Orders that belong to the user.
  final List<Order> orders;

  /// Whether the user is currently blocked from authenticating.
  final bool isBlocked;

  /// Indicates if this user is the one that сейчас авторизован в приложении.
  final bool isActive;

  /// Human readable name that falls back to phone/identifier when пусто.
  String get displayName =>
      profile.fullName.isNotEmpty ? profile.fullName : fallbackPhone;

  /// Returns a readable phone or a friendly placeholder for guests.
  String get fallbackPhone {
    if (profile.phone.isNotEmpty) {
      return profile.phone;
    }
    if (phone.startsWith('guest-')) {
      return 'Гость';
    }
    final formatted = phoneLabel;
    return formatted.isNotEmpty ? formatted : 'Не указан';
  }

  /// Total count of orders оформленных пользователем.
  int get orderCount => orders.length;

  /// Общая сумма заказов пользователя.
  double get totalSpent =>
      orders.fold(0, (sum, order) => sum + order.total);

  /// True when пользователь имеет реальный номер телефона и его можно блокировать.
  bool get canBeBlocked => _digits.hasMatch(phone);

  /// Форматированный вариант нормализованного телефона.
  String get phoneLabel {
    if (phone.startsWith('guest-')) {
      return 'Гость';
    }
    if (!_digits.hasMatch(phone)) {
      return phone;
    }
    if (phone.length == 11 && phone.startsWith('7')) {
      final buffer = StringBuffer('+7 ')
        ..write('(${phone.substring(1, 4)}) ')
        ..write('${phone.substring(4, 7)}-')
        ..write('${phone.substring(7, 9)}-')
        ..write(phone.substring(9, 11));
      return buffer.toString();
    }
    return '+$phone';
  }

  static final _digits = RegExp(r'^\d{10,}$');
}
