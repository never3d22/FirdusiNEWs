import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/admin_user.dart';
import '../data/models/category.dart';
import '../data/models/dish.dart';
import '../data/models/order.dart';
import '../data/models/restaurant_info.dart';
import '../data/models/restaurant_settings.dart';
import '../services/backend_service.dart';
class AppState extends ChangeNotifier {
  AppState({BackendService? backend}) : _backend = backend ?? MockBackendService();

  final BackendService _backend;

  static const _profileKey = 'profile';
  static const _ordersKey = 'orders';
  static const _activeOrderKey = 'activeOrder';
  static const _cartKey = 'cart';
  static const _deliveryModeKey = 'deliveryMode';
  static const _paymentMethodKey = 'paymentMethod';
  static const _customAddressKey = 'customAddress';
  static const _phoneKey = 'phone';
  static const _utensilsKey = 'utensils';
  static const _utensilsEnabledKey = 'utensilsEnabled';
  static const _authKey = 'auth';
  static const _restaurantNameKey = 'restaurantName';
  static const _restaurantAddressKey = 'restaurantAddress';
  static const _restaurantWorkingHoursKey = 'restaurantWorkingHours';
  static const _restaurantPhoneKey = 'restaurantPhone';
  static const _restaurantSettingsKey = 'restaurantSettings';
  static const _pickupIntervalKey = 'pickupInterval';
  static const _deliveryIntervalKey = 'deliveryInterval';
  static const _hiddenDishesKey = 'hiddenDishes';
  static const _customDishesKey = 'customDishes';
  static const _categoriesKey = 'categories';
  static const _adminOrdersKey = 'adminOrders';
  static const _blockedUsersKey = 'blockedUsers';
  static const _categoryFilterKey = 'categoryFilter';
  static const _adminAuthKey = 'adminAuth';
  static const _maxUtensilsCount = 10;

  static final Map<String, _TestUserData> _testUsers = {
    '79991234567': _TestUserData(
      password: 'firdusi2024',
      profile: const UserProfile(
        fullName: 'Иван Петров',
        phone: '+7 (999) 123-45-67',
        addresses: [
          'г. Казань, ул. Пушкина, д. 10',
          'г. Казань, пр-т Победы, д. 5',
        ],
        utensilsCount: 2,
        recentOrderIds: ['2024-0001', '2024-0007'],
      ),
      orders: [
        Order(
          id: '2024-0007',
          mode: DeliveryMode.delivery,
          status: OrderStatus.completed,
          paymentMethod: PaymentMethod.cardOnline,
          items: [
            OrderItem(
              dishId: 'pilaf',
              dishName: 'Плов по-татарски',
              dishPrice: 450.0,
              quantity: 2,
            ),
          ],
          createdAt: DateTime(2024, 5, 12, 18, 30),
          customerName: 'Иван Петров',
          phone: '+7 (999) 123-45-67',
          address: 'г. Казань, ул. Пушкина, д. 10',
          utensilsCount: 2,
        ),
        Order(
          id: '2024-0001',
          mode: DeliveryMode.pickup,
          status: OrderStatus.completed,
          paymentMethod: PaymentMethod.cash,
          items: [
            OrderItem(
              dishId: 'manty',
              dishName: 'Манты домашние',
              dishPrice: 320.0,
              quantity: 3,
            ),
          ],
          createdAt: DateTime(2024, 4, 28, 13, 10),
          customerName: 'Иван Петров',
          phone: '+7 (999) 123-45-67',
          address: 'Самовывоз',
          utensilsCount: 0,
        ),
      ],
    ),
    '79997654321': _TestUserData(
      password: 'dostavka',
      profile: const UserProfile(
        fullName: 'Алия Фирдусова',
        phone: '+7 (999) 765-43-21',
        addresses: [
          'г. Казань, ул. Баумана, д. 3',
        ],
        utensilsCount: 0,
        recentOrderIds: ['2024-0022'],
      ),
      orders: [
        Order(
          id: '2024-0022',
          mode: DeliveryMode.delivery,
          status: OrderStatus.pending,
          paymentMethod: PaymentMethod.cardCourier,
          items: [
            OrderItem(
              dishId: 'chudu',
              dishName: 'Чуду с сыром',
              dishPrice: 280.0,
              quantity: 1,
            ),
            OrderItem(
              dishId: 'tea',
              dishName: 'Чай с чабрецом',
              dishPrice: 120.0,
              quantity: 2,
            ),
          ],
          createdAt: DateTime(2024, 5, 18, 19, 15),
          customerName: 'Алия Фирдусова',
          phone: '+7 (999) 765-43-21',
          address: 'г. Казань, ул. Баумана, д. 3',
          utensilsCount: 0,
        ),
      ],
    ),
  };

  List<Category> _categories = [];
  List<Dish> _dishes = [];
  final Set<String> _selectedCategoryIds = <String>{};
  final Map<String, int> _cart = {};
  final Map<String, Order> _adminOrders = <String, Order>{};
  final Set<String> _blockedUsers = <String>{};
  DeliveryMode _deliveryMode = DeliveryMode.pickup;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  String _customAddress = '';
  String _phone = '';
  int _utensilsCount = 1;
  bool _utensilsEnabled = true;
  String? _selectedPickupInterval;
  String? _selectedDeliveryInterval;
  bool _isAuthenticated = false;
  bool _isAuthenticating = false;
  String? _authError;
  bool _isAdminAuthenticated = false;
  RestaurantInfo _restaurantInfo = const RestaurantInfo(
    name: 'Firdusi',
    address: 'г. Душанбе, ул. Фирдуоси, 1',
    workingHours: '10:00 – 22:00',
    phone: '+7 (999) 123-45-67',
  );
  RestaurantSettings _restaurantSettings = const RestaurantSettings(
    name: 'Firdusi',
    address: 'г. Душанбе, ул. Фирдуоси, 1',
    workingHours: '10:00 – 22:00',
    phone: '+7 (999) 123-45-67',
  );
  final Set<String> _hiddenDishIds = <String>{};
  int _timeSlotIntervalMinutes = 30;
  int _maxGeneratedSlots = 48;
  UserProfile _profile = const UserProfile(
    fullName: '',
    phone: '',
  );
  List<Order> _orders = [];
  String? _activeOrderId;
  bool _initialized = false;

  bool get isInitialized => _initialized;
  List<Category> get categories => _categories;
  List<Dish> get dishes => _dishes;
  String? get selectedCategoryId =>
      _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds.first;
  Set<String> get selectedCategoryIds => Set.unmodifiable(_selectedCategoryIds);
  Map<String, int> get cart => Map.unmodifiable(_cart);
  DeliveryMode get deliveryMode => _deliveryMode;
  PaymentMethod get paymentMethod => _paymentMethod;
  String get customAddress => _customAddress;
  String get phone => _phone.isNotEmpty ? _phone : _profile.phone;
  int get utensilsCount => _utensilsCount;
  bool get utensilsEnabled => _utensilsEnabled;
  int get maxUtensilsCount => _maxUtensilsCount;
  String? get selectedPickupInterval => _selectedPickupInterval;
  String? get selectedDeliveryInterval => _selectedDeliveryInterval;
  String? get selectedTimeSlot => selectedTimeSlotForMode(_deliveryMode);
  List<String> get availableTimeSlots =>
      availableTimeSlotsForMode(_deliveryMode);
  UserProfile get profile => _profile;
  List<Order> get orders => List.unmodifiable(_orders);
  List<Order> get adminOrders {
    final ordered = _adminOrders.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<Order>.unmodifiable(ordered);
  }
  bool get isAuthenticated => _isAuthenticated;
  bool get isAuthenticating => _isAuthenticating;
  String? get authError => _authError;
  bool get isAdminAuthenticated => _isAdminAuthenticated;
  List<MapEntry<String, String>> get demoCredentials =>
      _testUsers.values.map((user) => MapEntry(user.profile.phone, user.password)).toList();
  RestaurantInfo get restaurantInfo => _restaurantInfo;
  List<AdminUser> get adminUsers {
    final drafts = <String, _AdminUserDraft>{};
    void mergeProfile(String id, UserProfile profile) {
      final draft = drafts.putIfAbsent(id, () => _AdminUserDraft(id: id));
      draft.setProfile(profile);
    }

    for (final entry in _testUsers.entries) {
      final id = entry.key;
      mergeProfile(id, entry.value.profile);
      final draft = drafts[id]!;
      for (final order in entry.value.orders) {
        final stored = _adminOrders[order.id] ?? order;
        draft.orders[stored.id] = stored;
      }
    }

    for (final order in _adminOrders.values) {
      final normalized = _normalizePhone(order.phone);
      final id = normalized.isNotEmpty ? normalized : 'guest-${order.id}';
      mergeProfile(
        id,
        UserProfile(
          fullName: order.customerName,
          phone: order.phone,
          addresses: order.address.isNotEmpty ? [order.address] : const [],
          utensilsCount: order.utensilsCount,
          recentOrderIds: const [],
        ),
      );
      drafts[id]!.orders[order.id] = order;
    }

    final normalizedActive = _normalizePhone(_profile.phone);
    if (normalizedActive.isNotEmpty) {
      mergeProfile(normalizedActive, _profile);
      final draft = drafts[normalizedActive]!;
      for (final order in _orders) {
        draft.orders[order.id] = order;
      }
    }

    final users = drafts.values.map((draft) {
      final profile = draft.profile ??
          UserProfile(
            fullName: '',
            phone: draft.id.startsWith('guest-') ? '' : draft.id,
          );
      final userOrders = draft.orders.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final isActive =
          normalizedActive.isNotEmpty && draft.id == normalizedActive && _isAuthenticated;
      final isBlocked = draft.id.isNotEmpty && _blockedUsers.contains(draft.id);
      return AdminUser(
        phone: draft.id,
        profile: profile,
        orders: userOrders,
        isBlocked: isBlocked,
        isActive: isActive,
      );
    }).toList();

    users.sort((a, b) {
      final left = a.displayName.toLowerCase();
      final right = b.displayName.toLowerCase();
      final comparison = left.compareTo(right);
      if (comparison != 0) {
        return comparison;
      }
      return a.phone.compareTo(b.phone);
    });
    return users;
  }
  bool isUserBlocked(String phone) => _blockedUsers.contains(_normalizePhone(phone));
  String normalizedPhone(String value) => _normalizePhone(value);
  Order? get activeOrder {
    if (_activeOrderId == null) return null;
    try {
      return _orders.firstWhere((order) => order.id == _activeOrderId);
    } catch (_) {
      return null;
    }
  }

  List<Dish> get filteredDishes {
    final visibleDishes = _dishes.where((dish) => !dish.isHidden);
    if (_selectedCategoryIds.isEmpty) {
      return visibleDishes.toList();
    }
    return visibleDishes
        .where((dish) => _selectedCategoryIds.contains(dish.categoryId))
        .toList();
  }

  double get cartTotal {
    _removeMissingCartEntriesSync();
    var total = 0.0;
    for (final entry in _cart.entries) {
      final dish = _findDishById(entry.key);
      if (dish == null || dish.isHidden) continue;
      total += dish.price * entry.value;
    }
    return total;
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    final ordersJson = prefs.getString(_ordersKey);
    final activeOrderId = prefs.getString(_activeOrderKey);
    final cartJson = prefs.getString(_cartKey);
    final deliveryModeName = prefs.getString(_deliveryModeKey);
    final paymentName = prefs.getString(_paymentMethodKey);
    final restaurantSettingsJson = prefs.getString(_restaurantSettingsKey);
    final restaurantName = prefs.getString(_restaurantNameKey);
    final restaurantAddress = prefs.getString(_restaurantAddressKey);
    final restaurantWorkingHours = prefs.getString(_restaurantWorkingHoursKey);
    final restaurantPhone = prefs.getString(_restaurantPhoneKey);
    final legacyRestaurantInfoJson = prefs.getString('restaurantInfo');
    final storedPickupInterval = prefs.getString(_pickupIntervalKey);
    final storedDeliveryInterval = prefs.getString(_deliveryIntervalKey);
    final hiddenDishIds = prefs.getStringList(_hiddenDishesKey);
    final categoriesJson = prefs.getString(_categoriesKey);
    final customDishesJson = prefs.getString(_customDishesKey);
    final adminOrdersJson = prefs.getString(_adminOrdersKey);
    final blockedUsers = prefs.getStringList(_blockedUsersKey);
    final storedCategoryFilter = prefs.getStringList(_categoryFilterKey);
    final storedUtensilsCount = prefs.getInt(_utensilsKey);
    final storedUtensilsEnabled = prefs.getBool(_utensilsEnabledKey);

    _isAdminAuthenticated = prefs.getBool(_adminAuthKey) ?? false;

    _customAddress = prefs.getString(_customAddressKey) ?? '';
    _phone = prefs.getString(_phoneKey) ?? '';
    _selectedPickupInterval = _normalizeStoredSlot(storedPickupInterval);
    _selectedDeliveryInterval = _normalizeStoredSlot(storedDeliveryInterval);
    _isAuthenticated = prefs.getBool(_authKey) ?? false;

    _restaurantSettings = RestaurantSettings(
      name: _restaurantInfo.name,
      address: _restaurantInfo.address,
      workingHours: _restaurantInfo.workingHours,
      phone: _restaurantInfo.phone,
    );

    var migratedLegacyInfo = false;
    if (restaurantSettingsJson != null) {
      try {
        final decoded =
            jsonDecode(restaurantSettingsJson) as Map<String, dynamic>;
        final storedSettings = RestaurantSettings.fromJson(decoded);
        _restaurantSettings = RestaurantSettings(
          name: storedSettings.name.isNotEmpty
              ? storedSettings.name
              : _restaurantSettings.name,
          address: storedSettings.address.isNotEmpty
              ? storedSettings.address
              : _restaurantSettings.address,
          workingHours: storedSettings.workingHours.isNotEmpty
              ? storedSettings.workingHours
              : _restaurantSettings.workingHours,
          phone: storedSettings.phone.isNotEmpty
              ? storedSettings.phone
              : _restaurantSettings.phone,
        );
      } catch (_) {
        // Ignore corrupted data and keep defaults.
      }
    } else if (restaurantName != null ||
        restaurantAddress != null ||
        restaurantWorkingHours != null ||
        restaurantPhone != null) {
      _restaurantSettings = RestaurantSettings(
        name: restaurantName ?? _restaurantSettings.name,
        address: restaurantAddress ?? _restaurantSettings.address,
        workingHours:
            restaurantWorkingHours ?? _restaurantSettings.workingHours,
        phone: restaurantPhone ?? _restaurantSettings.phone,
      );
    } else if (legacyRestaurantInfoJson != null) {
      final legacyInfo = RestaurantInfo.fromJson(
        jsonDecode(legacyRestaurantInfoJson) as Map<String, dynamic>,
      );
      _restaurantSettings = RestaurantSettings(
        name: legacyInfo.name,
        address: legacyInfo.address.isNotEmpty
            ? legacyInfo.address
            : _restaurantSettings.address,
        workingHours: legacyInfo.workingHours,
        phone: legacyInfo.phone,
      );
      migratedLegacyInfo = true;
    }

    _restaurantInfo = _restaurantInfo.copyWith(
      name: _restaurantSettings.name.isNotEmpty
          ? _restaurantSettings.name
          : _restaurantInfo.name,
      address: _restaurantSettings.address.isNotEmpty
          ? _restaurantSettings.address
          : _restaurantInfo.address,
      workingHours: _restaurantSettings.workingHours.isNotEmpty
          ? _restaurantSettings.workingHours
          : _restaurantInfo.workingHours,
      phone: _restaurantSettings.phone.isNotEmpty
          ? _restaurantSettings.phone
          : _restaurantInfo.phone,
    );

    if (migratedLegacyInfo) {
      await prefs.remove('restaurantInfo');
      await _persistRestaurantInfo(prefs);
    }

    _hiddenDishIds
      ..clear()
      ..addAll(hiddenDishIds ?? const []);

    _blockedUsers
      ..clear()
      ..addAll(
        (blockedUsers ?? const <String>[])
            .map(_normalizePhone)
            .where((value) => value.isNotEmpty),
      );

    _adminOrders.clear();
    if (adminOrdersJson != null) {
      try {
        final decoded =
            (jsonDecode(adminOrdersJson) as List<dynamic>).cast<Map<String, dynamic>>();
        for (final data in decoded) {
          final order = Order.fromJson(data);
          _adminOrders[order.id] = order;
        }
      } catch (_) {
        _adminOrders.clear();
      }
    }
    for (final entry in _testUsers.entries) {
      for (final order in entry.value.orders) {
        _adminOrders.putIfAbsent(order.id, () => order);
      }
    }

    final storedCategoryMap = <String, Category>{};
    if (categoriesJson != null) {
      final decoded =
          (jsonDecode(categoriesJson) as List<dynamic>).cast<Map<String, dynamic>>();
      for (final data in decoded) {
        final category = Category.fromJson(data);
        storedCategoryMap[category.id] = category;
      }
    }

    final storedDishMap = <String, Dish>{};
    if (customDishesJson != null) {
      final decoded =
          (jsonDecode(customDishesJson) as List<dynamic>).cast<Map<String, dynamic>>();
      for (final data in decoded) {
        final dish = Dish.fromJson(data);
        storedDishMap[dish.id] = dish;
      }
    }

    final loadedCategories = await _backend.loadCategories();
    final loadedDishes = await _backend.loadDishes();

    _categories = [
      for (final category in loadedCategories)
        storedCategoryMap.remove(category.id) ?? category,
      ...storedCategoryMap.values,
    ];

    _selectedCategoryIds
      ..clear()
      ..addAll(
        (storedCategoryFilter ?? const <String>[])
            .where((id) => id.isNotEmpty),
      );

    final combinedDishes = <Dish>[];
    for (final dish in loadedDishes) {
      final override = storedDishMap.remove(dish.id);
      final effective = override ?? dish;
      final isHidden = _hiddenDishIds.contains(effective.id) || effective.isHidden;
      if (isHidden) {
        _hiddenDishIds.add(effective.id);
      }
      combinedDishes.add(effective.copyWith(isHidden: isHidden));
    }
    for (final dish in storedDishMap.values) {
      final isHidden = _hiddenDishIds.contains(dish.id) || dish.isHidden;
      if (isHidden) {
        _hiddenDishIds.add(dish.id);
      }
      combinedDishes.add(dish.copyWith(isHidden: isHidden));
    }
    _dishes = combinedDishes;

    final availableCategoryIds = _categories.map((category) => category.id).toSet();
    _selectedCategoryIds.removeWhere((id) => !availableCategoryIds.contains(id));

    if (profileJson != null) {
      _profile =
          UserProfile.fromJson(jsonDecode(profileJson) as Map<String, dynamic>);
    }
    var effectiveUtensilsCount =
        (storedUtensilsCount ?? _profile.utensilsCount).clamp(0, _maxUtensilsCount).toInt();
    if (effectiveUtensilsCount <= 0) {
      effectiveUtensilsCount = 1;
    }
    _utensilsCount = effectiveUtensilsCount;
    _utensilsEnabled = storedUtensilsEnabled ?? true;
    if (_utensilsEnabled && _utensilsCount <= 0) {
      _utensilsCount = 1;
    }
    if (_profile.utensilsCount != (_utensilsEnabled ? _utensilsCount : 0)) {
      _profile = _profile.copyWith(
        utensilsCount: _utensilsEnabled ? _utensilsCount : 0,
      );
    }

    if (ordersJson != null) {
      final data =
          (jsonDecode(ordersJson) as List<dynamic>).cast<Map<String, dynamic>>();
      _orders = data.map(Order.fromJson).toList();
      for (final order in _orders) {
        _adminOrders[order.id] = order;
      }
    }
    if (_orders.isNotEmpty) {
      _profile = _profile.copyWith(
        recentOrderIds: _orders.map((order) => order.id).take(10).toList(),
      );
    }
    _activeOrderId = activeOrderId;

    if (restaurantName != null ||
        restaurantAddress != null ||
        restaurantWorkingHours != null ||
        restaurantPhone != null) {
      _restaurantInfo = _restaurantInfo.copyWith(
        name: restaurantName ?? _restaurantInfo.name,
        address: restaurantAddress ?? _restaurantInfo.address,
        workingHours: restaurantWorkingHours ?? _restaurantInfo.workingHours,
        phone: restaurantPhone ?? _restaurantInfo.phone,
      );
    } else if (legacyRestaurantInfoJson != null) {
      final legacyInfo = RestaurantInfo.fromJson(
        jsonDecode(legacyRestaurantInfoJson) as Map<String, dynamic>,
      );
      _restaurantSettings = _restaurantSettings.copyWith(
        name: legacyInfo.name,
        address: legacyInfo.address.isNotEmpty
            ? legacyInfo.address
            : _restaurantInfo.address,
        workingHours: legacyInfo.workingHours,
        phone: legacyInfo.phone,
      );
      await prefs.remove('restaurantInfo');
      await _persistRestaurantInfo(prefs);
    }

    _cart.clear();
    if (cartJson != null) {
      final decoded = jsonDecode(cartJson) as Map<String, dynamic>;
      for (final entry in decoded.entries) {
        _cart[entry.key] = entry.value as int;
      }
    }

    if (deliveryModeName != null) {
      _deliveryMode = DeliveryMode.values.firstWhere(
        (element) => element.name == deliveryModeName,
        orElse: () => DeliveryMode.pickup,
      );
    }
    if (paymentName != null) {
      _paymentMethod = PaymentMethod.values.firstWhere(
        (element) => element.name == paymentName,
        orElse: () => PaymentMethod.cash,
      );
    }

    if (_profile.phone.isEmpty && _phone.isNotEmpty) {
      _profile = _profile.copyWith(phone: _phone);
    }

    _sanitizeTimeSlots();

    _initialized = true;
    notifyListeners();
  }

  Future<void> _persist([SharedPreferences? prefs]) async {
    final preferences = prefs ?? await SharedPreferences.getInstance();
    _profile = _profile.copyWith(
      utensilsCount: _utensilsEnabled ? _utensilsCount : 0,
    );
    await preferences.setString(_profileKey, jsonEncode(_profile.toJson()));
    await preferences.setString(
      _ordersKey,
      jsonEncode(_orders.map((e) => e.toJson()).toList()),
    );
    if (_activeOrderId != null) {
      await preferences.setString(_activeOrderKey, _activeOrderId!);
    } else {
      await preferences.remove(_activeOrderKey);
    }
    await preferences.setString(_cartKey, jsonEncode(_cart));
    await preferences.setString(_deliveryModeKey, _deliveryMode.name);
    await preferences.setString(_paymentMethodKey, _paymentMethod.name);
    await preferences.setString(_customAddressKey, _customAddress);
    await preferences.setString(_phoneKey, _phone);
    await preferences.setInt(_utensilsKey, _utensilsCount);
    await preferences.setBool(_utensilsEnabledKey, _utensilsEnabled);
    await preferences.setStringList(
      _categoryFilterKey,
      _selectedCategoryIds.toList(),
    );
    await preferences.setBool(_adminAuthKey, _isAdminAuthenticated);
    await preferences.setBool(_authKey, _isAuthenticated);
    if (_selectedPickupInterval != null) {
      await preferences.setString(_pickupIntervalKey, _selectedPickupInterval!);
    } else {
      await preferences.remove(_pickupIntervalKey);
    }
    if (_selectedDeliveryInterval != null) {
      await preferences.setString(
        _deliveryIntervalKey,
        _selectedDeliveryInterval!,
      );
    } else {
      await preferences.remove(_deliveryIntervalKey);
    }
    await _persistRestaurantInfo(preferences);
    await _persistAdminOrders(preferences);
    await _persistBlockedUsers(preferences);
  }

  Future<void> _persistRestaurantInfo([SharedPreferences? prefs]) async {
    final preferences = prefs ?? await SharedPreferences.getInstance();
    await preferences.setString(_restaurantNameKey, _restaurantInfo.name);
    await preferences.setString(_restaurantAddressKey, _restaurantInfo.address);
    await preferences.setString(
      _restaurantWorkingHoursKey,
      _restaurantInfo.workingHours,
    );
    await preferences.setString(_restaurantPhoneKey, _restaurantInfo.phone);
    await preferences.setString(
      _restaurantSettingsKey,
      jsonEncode(_restaurantSettings.toJson()),
    );
  }

  Future<void> _persistHiddenDishes([SharedPreferences? prefs]) async {
    final preferences = prefs ?? await SharedPreferences.getInstance();
    await preferences.setStringList(_hiddenDishesKey, _hiddenDishIds.toList());
  }

  Future<void> _persistCustomDishes([SharedPreferences? prefs]) async {
    final preferences = prefs ?? await SharedPreferences.getInstance();
    await preferences.setString(
      _customDishesKey,
      jsonEncode(_dishes.map((dish) => dish.toJson()).toList()),
    );
  }

  Future<void> _persistCategories([SharedPreferences? prefs]) async {
    final preferences = prefs ?? await SharedPreferences.getInstance();
    await preferences.setString(
      _categoriesKey,
      jsonEncode(_categories.map((category) => category.toJson()).toList()),
    );
  }

  Future<void> _persistAdminOrders([SharedPreferences? prefs]) async {
    final preferences = prefs ?? await SharedPreferences.getInstance();
    await preferences.setString(
      _adminOrdersKey,
      jsonEncode(_adminOrders.values.map((order) => order.toJson()).toList()),
    );
  }

  Future<void> _persistBlockedUsers([SharedPreferences? prefs]) async {
    final preferences = prefs ?? await SharedPreferences.getInstance();
    await preferences.setStringList(_blockedUsersKey, _blockedUsers.toList());
  }

  String? _normalizeStoredSlot(String? slot) {
    if (slot == null) return null;
    final match =
        RegExp(r'^(\s*)(\d{1,2}:\d{2})\s*[–-]\s*(\d{1,2}:\d{2})(\s*)$').firstMatch(slot);
    if (match == null) {
      return null;
    }
    final start = match.group(2)!;
    final end = match.group(3)!;
    return '$start – $end';
  }

  void _sanitizeTimeSlots() {
    String? sanitize(List<String> slots, String? current) {
      final normalized = _normalizeStoredSlot(current);
      if (normalized != null && slots.contains(normalized)) {
        return normalized;
      }
      if (normalized == null && current == null) {
        return null;
      }
      return slots.isNotEmpty ? slots.first : null;
    }

    final pickupSlots = availableTimeSlotsForMode(DeliveryMode.pickup);
    final deliverySlots = availableTimeSlotsForMode(DeliveryMode.delivery);

    _selectedPickupInterval = sanitize(pickupSlots, _selectedPickupInterval);
    _selectedDeliveryInterval = sanitize(deliverySlots, _selectedDeliveryInterval);
  }

  List<DateTime>? _parseWorkingHoursRange(DateTime reference) {
    final workingHours = _restaurantInfo.workingHours.trim();
    if (workingHours.isEmpty) {
      return null;
    }
    final match =
        RegExp(r'^(\d{1,2}):(\d{2})\s*[–-]\s*(\d{1,2}):(\d{2})$').firstMatch(workingHours);
    if (match == null) {
      return null;
    }
    final startHour = int.tryParse(match.group(1)!);
    final startMinute = int.tryParse(match.group(2)!);
    final endHour = int.tryParse(match.group(3)!);
    final endMinute = int.tryParse(match.group(4)!);
    if (startHour == null ||
        startMinute == null ||
        endHour == null ||
        endMinute == null) {
      return null;
    }
    var start = DateTime(reference.year, reference.month, reference.day, startHour, startMinute);
    var end = DateTime(reference.year, reference.month, reference.day, endHour, endMinute);
    if (!end.isAfter(start)) {
      end = end.add(const Duration(days: 1));
    }
    return [start, end];
  }

  DateTime _ceilToInterval(DateTime time, int intervalMinutes) {
    if (intervalMinutes <= 0) {
      return time;
    }
    final base = DateTime(time.year, time.month, time.day, time.hour, time.minute);
    var minutesFromMidnight = base.hour * 60 + base.minute;
    if (time.isAfter(base)) {
      minutesFromMidnight += 1;
    }
    final remainder = minutesFromMidnight % intervalMinutes;
    if (remainder != 0) {
      minutesFromMidnight += intervalMinutes - remainder;
    }
    final hours = minutesFromMidnight ~/ 60;
    final minutes = minutesFromMidnight % 60;
    return DateTime(base.year, base.month, base.day, hours, minutes);
  }

  String _formatTime(DateTime time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  Future<void> updateRestaurantSettings(RestaurantSettings settings) async {
    _restaurantSettings = settings;
    _restaurantInfo = _restaurantInfo.copyWith(
      name: settings.name,
      address: settings.address,
      workingHours: settings.workingHours,
      phone: settings.phone,
    );
    _sanitizeTimeSlots();
    await _persist();
    notifyListeners();
  }

  Future<void> updateRestaurantName(String name) {
    return updateRestaurantSettings(_restaurantSettings.copyWith(name: name));
  }

  Future<void> updateRestaurantWorkingHours(String workingHours) {
    return updateRestaurantSettings(
      _restaurantSettings.copyWith(workingHours: workingHours),
    );
  }

  Future<void> updateRestaurantPhone(String phone) {
    return updateRestaurantSettings(_restaurantSettings.copyWith(phone: phone));
  }

  Future<void> updateRestaurantInfo(RestaurantInfo info) {
    return updateRestaurantSettings(
      RestaurantSettings(
        name: info.name,
        address: info.address,
        workingHours: info.workingHours,
        phone: info.phone,
      ),
    );
  }

  

  Future<Category> addCategory(String title) async {
    final base = DateTime.now().millisecondsSinceEpoch;
    var counter = 0;
    String nextId() {
      return 'category_${base + counter++}';
    }

    var id = 'category_$base';
    while (_categories.any((category) => category.id == id)) {
      id = nextId();
    }

    final category = Category(id: id, title: title);
    _categories = [..._categories, category];
    final prefs = await SharedPreferences.getInstance();
    await _persistCategories(prefs);
    notifyListeners();
    return category;
  }

  Future<void> updateCategoryTitle(String categoryId, String title) async {
    final index = _categories.indexWhere((category) => category.id == categoryId);
    if (index == -1) {
      return;
    }
    _categories[index] = Category(id: categoryId, title: title);
    final prefs = await SharedPreferences.getInstance();
    await _persistCategories(prefs);
    notifyListeners();
  }

  void clearCategoryFilter() {
    if (_selectedCategoryIds.isEmpty) {
      return;
    }
    _selectedCategoryIds.clear();
    unawaited(_persist());
    notifyListeners();
  }

  void selectCategory(String? id) {
    if (id == null) {
      clearCategoryFilter();
      return;
    }
    if (_selectedCategoryIds.length == 1 && _selectedCategoryIds.contains(id)) {
      return;
    }
    _selectedCategoryIds
      ..clear()
      ..add(id);
    unawaited(_persist());
    notifyListeners();
  }

  void setCategoryFilter(Set<String> categoryIds) {
    final validIds = categoryIds
        .where((id) => _categories.any((category) => category.id == id))
        .toSet();
    final currentLength = _selectedCategoryIds.length;
    if (validIds.length == currentLength &&
        validIds.every(_selectedCategoryIds.contains)) {
      return;
    }
    _selectedCategoryIds
      ..clear()
      ..addAll(validIds);
    unawaited(_persist());
    notifyListeners();
  }

  Future<bool> removeCategory(String categoryId) async {
    if (hasDishesInCategory(categoryId)) {
      return false;
    }
    final exists = _categories.any((category) => category.id == categoryId);
    if (!exists) {
      return false;
    }
    _categories = _categories.where((category) => category.id != categoryId).toList();
    final removedFromFilter = _selectedCategoryIds.remove(categoryId);
    final prefs = await SharedPreferences.getInstance();
    await _persistCategories(prefs);
    if (removedFromFilter) {
      await _persist(prefs);
    }
    notifyListeners();
    return true;
  }

  bool hasDishesInCategory(String categoryId) {
    return _dishes.any((dish) => dish.categoryId == categoryId);
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _categories.length) return;
    if (newIndex < 0 || newIndex > _categories.length) return;
    final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    if (adjustedNewIndex == oldIndex) return;
    final updated = List<Category>.from(_categories);
    final category = updated.removeAt(oldIndex);
    updated.insert(adjustedNewIndex, category);
    _categories = updated;
    final prefs = await SharedPreferences.getInstance();
    await _persistCategories(prefs);
    notifyListeners();
  }

  void addDish(Dish dish) {
    if (dish.isHidden) {
      return;
    }
    _cart.update(dish.id, (value) => value + 1, ifAbsent: () => 1);
    _persist();
    notifyListeners();
  }

  void incrementDish(String dishId) {
    if (_cart.containsKey(dishId)) {
      _cart[dishId] = _cart[dishId]! + 1;
      _persist();
      notifyListeners();
    }
  }

  void decrementDish(String dishId) {
    if (!_cart.containsKey(dishId)) return;
    final current = _cart[dishId]! - 1;
    if (current <= 0) {
      _cart.remove(dishId);
    } else {
      _cart[dishId] = current;
    }
    _persist();
    notifyListeners();
  }

  Future<void> removeDish(String dishId) async {
    if (_cart.remove(dishId) != null) {
      await _persist();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _cart.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> toggleDishHidden(String dishId) async {
    final index = _dishes.indexWhere((dish) => dish.id == dishId);
    if (index == -1) return;
    final dish = _dishes[index];
    final updated = dish.copyWith(isHidden: !dish.isHidden);
    _dishes[index] = updated;
    if (updated.isHidden) {
      _hiddenDishIds.add(dishId);
      _cart.remove(dishId);
    } else {
      _hiddenDishIds.remove(dishId);
    }
    final prefs = await SharedPreferences.getInstance();
    await _persistHiddenDishes(prefs);
    await _persist(prefs);
    notifyListeners();
  }

  Future<void> updateDish(Dish updatedDish) async {
    final index = _dishes.indexWhere((dish) => dish.id == updatedDish.id);
    if (index == -1) return;
    _dishes[index] = updatedDish;
    if (updatedDish.isHidden) {
      _hiddenDishIds.add(updatedDish.id);
      _cart.remove(updatedDish.id);
    } else {
      _hiddenDishIds.remove(updatedDish.id);
    }
    final prefs = await SharedPreferences.getInstance();
    await _persistHiddenDishes(prefs);
    await _persistCustomDishes(prefs);
    await _persist(prefs);
    notifyListeners();
  }

  Future<Dish> createDish({
    required String name,
    required String description,
    required String categoryId,
    required double price,
    required int weight,
    required String imageUrl,
    bool isHidden = false,
  }) async {
    final base = DateTime.now().millisecondsSinceEpoch;
    var counter = 0;
    String id;
    do {
      id = 'dish_${base + counter++}';
    } while (_dishes.any((dish) => dish.id == id));

    final dish = Dish(
      id: id,
      name: name,
      description: description,
      categoryId: categoryId,
      price: price,
      weight: weight,
      imageUrl: imageUrl,
      isHidden: isHidden,
    );

    _dishes = [..._dishes, dish];
    if (isHidden) {
      _hiddenDishIds.add(dish.id);
    } else {
      _hiddenDishIds.remove(dish.id);
    }
    final prefs = await SharedPreferences.getInstance();
    await _persistHiddenDishes(prefs);
    await _persistCustomDishes(prefs);
    await _persist(prefs);
    notifyListeners();
    return dish;
  }

  Future<void> deleteDish(String dishId) async {
    final index = _dishes.indexWhere((dish) => dish.id == dishId);
    if (index == -1) return;
    final removed = _dishes.removeAt(index);
    _hiddenDishIds.remove(removed.id);
    _cart.remove(removed.id);
    final prefs = await SharedPreferences.getInstance();
    await _persistHiddenDishes(prefs);
    await _persistCustomDishes(prefs);
    await _persist(prefs);
    notifyListeners();
  }

  Future<void> setUserBlocked(String phone, bool blocked) async {
    final normalized = _normalizePhone(phone);
    if (normalized.isEmpty) return;
    final changed = blocked
        ? _blockedUsers.add(normalized)
        : _blockedUsers.remove(normalized);
    if (!changed) return;
    await _persistBlockedUsers();
    notifyListeners();
  }

  Future<void> toggleUserBlocked(String phone) {
    final normalized = _normalizePhone(phone);
    final shouldBlock = !_blockedUsers.contains(normalized);
    return setUserBlocked(phone, shouldBlock);
  }

  void setDeliveryMode(DeliveryMode mode) {
    _deliveryMode = mode;
    _sanitizeTimeSlots();
    _persist();
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    _persist();
    notifyListeners();
  }

  void setCustomAddress(String address) {
    _customAddress = address;
    _persist();
    notifyListeners();
  }

  void setPhone(String phone) {
    _phone = phone;
    _persist();
    notifyListeners();
  }

  void setUtensilsCount(int count) {
    final normalized = count.clamp(0, _maxUtensilsCount).toInt();
    final resolved = !_utensilsEnabled && normalized == 0
        ? 0
        : (normalized == 0 ? 1 : normalized);
    if (_utensilsCount == resolved) return;
    _utensilsCount = resolved;
    _persist();
    notifyListeners();
  }

  void setUtensilsEnabled(bool value) {
    if (_utensilsEnabled == value) return;
    _utensilsEnabled = value;
    if (_utensilsEnabled && _utensilsCount <= 0) {
      _utensilsCount = 1;
    }
    _persist();
    notifyListeners();
  }

  List<String> availableTimeSlotsForMode(DeliveryMode mode) {
    final now = DateTime.now();
    final range = _parseWorkingHoursRange(now);
    DateTime start;
    DateTime end;
    if (range != null) {
      start = range[0];
      end = range[1];
      if (now.isAfter(start)) {
        start = now;
      }
    } else {
      start = now;
      final fallbackDuration =
          mode == DeliveryMode.delivery ? const Duration(hours: 6) : const Duration(hours: 4);
      end = now.add(fallbackDuration);
    }

    if (!end.isAfter(start)) {
      return const [];
    }

    var slotStart = _ceilToInterval(start, _timeSlotIntervalMinutes);
    final slots = <String>[];
    for (var i = 0; i < _maxGeneratedSlots; i++) {
      if (!slotStart.isBefore(end)) {
        break;
      }
      final slotEnd =
          slotStart.add(Duration(minutes: _timeSlotIntervalMinutes));
      if (slotEnd.isAfter(end)) {
        break;
      }
      slots.add('${_formatTime(slotStart)} – ${_formatTime(slotEnd)}');
      slotStart = slotEnd;
    }

    if (slots.isEmpty && range == null) {
      slotStart = _ceilToInterval(now, _timeSlotIntervalMinutes);
      for (var i = 0; i < 4; i++) {
        final slotEnd =
            slotStart.add(Duration(minutes: _timeSlotIntervalMinutes));
        slots.add('${_formatTime(slotStart)} – ${_formatTime(slotEnd)}');
        slotStart = slotEnd;
      }
    }

    return slots;
  }

  String? selectedTimeSlotForMode(DeliveryMode mode) {
    return mode == DeliveryMode.pickup
        ? _selectedPickupInterval
        : _selectedDeliveryInterval;
  }

  void setSelectedTimeSlot(String? slot) {
    setSelectedTimeSlotForMode(_deliveryMode, slot);
  }

  void setSelectedTimeSlotForMode(DeliveryMode mode, String? slot) {
    final normalized = _normalizeStoredSlot(slot);
    final slots = availableTimeSlotsForMode(mode);
    final updatedValue = normalized == null
        ? null
        : (slots.contains(normalized)
            ? normalized
            : (slots.isNotEmpty ? slots.first : null));

    if (mode == DeliveryMode.pickup) {
      if (_selectedPickupInterval == updatedValue) return;
      _selectedPickupInterval = updatedValue;
    } else {
      if (_selectedDeliveryInterval == updatedValue) return;
      _selectedDeliveryInterval = updatedValue;
    }
    _persist();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _profile = profile;
    if (_profile.phone.isNotEmpty) {
      _phone = _profile.phone;
    }
    var utensilsFromProfile = profile.utensilsCount;
    if (utensilsFromProfile < 0) {
      utensilsFromProfile = 0;
    }
    if (utensilsFromProfile > _maxUtensilsCount) {
      utensilsFromProfile = _maxUtensilsCount;
    }
    _utensilsCount = utensilsFromProfile;
    _utensilsEnabled = utensilsFromProfile > 0;
    await _persist();
    notifyListeners();
  }

  Future<bool> signInWithPassword(String phone, String password) async {
    final normalized = _normalizePhone(phone);
    _isAuthenticating = true;
    _authError = null;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (_blockedUsers.contains(normalized)) {
      _isAuthenticating = false;
      _authError = 'Этот аккаунт заблокирован администратором.';
      notifyListeners();
      return false;
    }

    final userData = _testUsers[normalized];
    if (userData == null || userData.password != password.trim()) {
      _isAuthenticating = false;
      _authError = 'Неверный номер телефона или пароль.';
      notifyListeners();
      return false;
    }

    _isAuthenticated = true;
    _profile = userData.profile.copyWith(
      recentOrderIds: userData.orders.map((order) => order.id).toList(),
    );
    _orders = List<Order>.from(userData.orders);
    for (final order in _orders) {
      _adminOrders[order.id] = order;
    }
    _activeOrderId = _orders.isNotEmpty ? _orders.first.id : null;
    _phone = _profile.phone.isNotEmpty ? _profile.phone : phone.trim();
    _utensilsCount = _profile.utensilsCount.clamp(0, _maxUtensilsCount).toInt();
    _utensilsEnabled = _utensilsCount > 0;
    _customAddress = '';
    _cart.clear();
    _isAuthenticating = false;
    await _persistAdminOrders();
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _authError = null;
    _isAuthenticating = false;
    _phone = '';
    _profile = const UserProfile(fullName: '', phone: '');
    _orders = [];
    _activeOrderId = null;
    _customAddress = '';
    _cart.clear();
    _utensilsCount = 1;
    _utensilsEnabled = true;
    await _persist();
    notifyListeners();
  }

  Future<bool> signInAdmin(String login, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final normalizedLogin = login.trim();
    final normalizedPassword = password.trim();
    final isValid =
        normalizedLogin == 'admin' && normalizedPassword == '1234';
    if (!isValid) {
      return false;
    }
    if (_isAdminAuthenticated) {
      return true;
    }
    _isAdminAuthenticated = true;
    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> signOutAdmin() async {
    if (!_isAdminAuthenticated) {
      return;
    }
    _isAdminAuthenticated = false;
    await _persist();
    notifyListeners();
  }

  Future<void> checkout() async {
    if (_cart.isEmpty) return;
    await removeInvalidCartItems();
    if (_cart.isEmpty) return;
    final items = <OrderItem>[];
    for (final entry in _cart.entries) {
      final dish = _findDishById(entry.key);
      if (dish == null) continue;
      items.add(
        OrderItem(
          dishId: dish.id,
          dishName: dish.name,
          dishPrice: dish.price,
          quantity: entry.value,
        ),
      );
    }
    if (items.isEmpty) return;

    final selectedInterval = selectedTimeSlotForMode(_deliveryMode);
    final pickupAddress = _restaurantInfo.address.isNotEmpty
        ? _restaurantInfo.address
        : 'Самовывоз';
    final deliveryAddress =
        _customAddress.isNotEmpty ? _customAddress : _profile.defaultAddress;
    final utensilsForOrder = _utensilsEnabled ? _utensilsCount : 0;
    final orderPhone = phone.trim();
    if (orderPhone.isEmpty) {
      return;
    }

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mode: _deliveryMode,
      status: OrderStatus.pending,
      paymentMethod: _paymentMethod,
      items: items,
      createdAt: DateTime.now(),
      customerName: _profile.fullName,
      phone: orderPhone,
      address:
          _deliveryMode == DeliveryMode.pickup ? pickupAddress : deliveryAddress,
      utensilsCount: utensilsForOrder,
      deliveryInterval: selectedInterval,
      cancellationReason: null,
    );

    _profile = _profile.copyWith(
      recentOrderIds: [
        order.id,
        ..._profile.recentOrderIds.where((id) => id != order.id).take(9),
      ],
    );
    _orders.insert(0, order);
    _activeOrderId = order.id;
    _adminOrders[order.id] = order;
    await _backend.submitOrder(order);
    await _persistAdminOrders();
    await clearCart();
  }

  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? cancellationReason,
  }) async {
    var hasChanges = false;
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final updated = _orders[index].copyWith(
        status: status,
        cancellationReason: status == OrderStatus.cancelled
            ? (cancellationReason ?? _orders[index].cancellationReason)
            : null,
      );
      _orders[index] = updated;
      hasChanges = true;
      if (_activeOrderId == orderId &&
          (status == OrderStatus.completed || status == OrderStatus.cancelled)) {
        _activeOrderId = null;
      }
    }
    final adminOrder = _adminOrders[orderId];
    if (adminOrder != null) {
      _adminOrders[orderId] = adminOrder.copyWith(
        status: status,
        cancellationReason: status == OrderStatus.cancelled
            ? (cancellationReason ?? adminOrder.cancellationReason)
            : null,
      );
      hasChanges = true;
    }
    if (!hasChanges) return;
    await _backend.updateOrderStatus(
      orderId,
      status,
      cancellationReason: status == OrderStatus.cancelled
          ? (cancellationReason ?? _adminOrders[orderId]?.cancellationReason)
          : null,
    );
    await _persistAdminOrders();
    await _persist();
    notifyListeners();
  }

  Future<void> cancelOrder(String orderId, String reason) {
    final trimmed = reason.trim();
    return updateOrderStatus(
      orderId,
      OrderStatus.cancelled,
      cancellationReason: trimmed.isNotEmpty ? trimmed : null,
    );
  }

  String _normalizePhone(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Dish? _findDishById(String dishId) {
    return _dishes.cast<Dish?>().firstWhere(
          (dish) => dish?.id == dishId,
          orElse: () => null,
        );
  }

  List<String> _collectMissingCartDishIds() {
    final missingIds = <String>[];
    for (final id in _cart.keys) {
      final dish = _findDishById(id);
      if (dish == null || dish.isHidden) {
        missingIds.add(id);
      }
    }
    return missingIds;
  }

  void _removeMissingCartEntriesSync() {
    final missingIds = _collectMissingCartDishIds();
    if (missingIds.isEmpty) {
      return;
    }
    for (final id in missingIds) {
      _cart.remove(id);
    }
    Future.microtask(() async {
      await _persist();
      notifyListeners();
    });
  }

  Future<void> removeInvalidCartItems() async {
    final missingIds = _collectMissingCartDishIds();
    if (missingIds.isEmpty) return;
    for (final id in missingIds) {
      _cart.remove(id);
    }
    await _persist();
    notifyListeners();
  }
}

class _AdminUserDraft {
  _AdminUserDraft({required this.id});

  final String id;
  UserProfile? profile;
  final Map<String, Order> orders = <String, Order>{};

  void setProfile(UserProfile candidate) {
    if (profile == null) {
      profile = candidate;
      return;
    }
    final current = profile!;
    var updated = current;
    if (candidate.fullName.isNotEmpty && current.fullName != candidate.fullName) {
      updated = updated.copyWith(fullName: candidate.fullName);
    }
    if (candidate.phone.isNotEmpty && current.phone != candidate.phone) {
      updated = updated.copyWith(phone: candidate.phone);
    }
    if (candidate.addresses.isNotEmpty && current.addresses != candidate.addresses) {
      updated = updated.copyWith(addresses: List<String>.from(candidate.addresses));
    }
    if (candidate.utensilsCount > 0 && candidate.utensilsCount != current.utensilsCount) {
      updated = updated.copyWith(utensilsCount: candidate.utensilsCount);
    }
    if (candidate.recentOrderIds.isNotEmpty &&
        candidate.recentOrderIds != current.recentOrderIds) {
      updated = updated.copyWith(recentOrderIds: candidate.recentOrderIds);
    }
    profile = updated;
  }
}

class _TestUserData {
  const _TestUserData({
    required this.password,
    required this.profile,
    required this.orders,
  });

  final String password;
  final UserProfile profile;
  final List<Order> orders;
}
