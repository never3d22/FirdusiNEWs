import 'dart:async';
import 'dart:io';

import '../data/models/category.dart';
import '../data/models/dish.dart';
import '../data/models/order.dart';

abstract class BackendService {
  Future<List<Category>> loadCategories();
  Future<List<Dish>> loadDishes();
  Future<void> submitOrder(Order order);
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? cancellationReason,
  });
}

class MockBackendService implements BackendService {
  final List<Category> _categories = const [
    Category(id: 'soups', title: 'Супы'),
    Category(id: 'salads', title: 'Салаты'),
    Category(id: 'hot', title: 'Горячее'),
    Category(id: 'desserts', title: 'Десерты'),
    Category(id: 'drinks', title: 'Напитки'),
  ];

  final List<Dish> _dishes = const [
    Dish(
      id: 'plov',
      name: 'Плов по-фергански',
      description: 'Сочный плов с говядиной, нутом и ароматными специями.',
      categoryId: 'hot',
      price: 390,
      weight: 350,
      imageUrl:
          'https://images.unsplash.com/photo-1612874742237-6526221588ff?auto=format&fit=crop&w=800&q=60',
    ),
    Dish(
      id: 'shashlik',
      name: 'Шашлык из баранины',
      description: 'Нежный шашлык, маринованный на специях Фирдуоси.',
      categoryId: 'hot',
      price: 520,
      weight: 300,
      imageUrl:
          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=60',
    ),
    Dish(
      id: 'lagman',
      name: 'Лагман классический',
      description: 'Ручная лапша, свежие овощи и душистая говядина.',
      categoryId: 'soups',
      price: 360,
      weight: 400,
      imageUrl:
          'https://images.unsplash.com/photo-1525755662778-989d0524087e?auto=format&fit=crop&w=800&q=60',
    ),
    Dish(
      id: 'chakchak',
      name: 'Чак-чак',
      description: 'Любимый восточный десерт с медом.',
      categoryId: 'desserts',
      price: 250,
      weight: 150,
      imageUrl:
          'https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&w=800&q=60',
    ),
    Dish(
      id: 'tea',
      name: 'Чай с травами',
      description: 'Горячий травяной чай с мятой и чабрецом.',
      categoryId: 'drinks',
      price: 90,
      weight: 300,
      imageUrl:
          'https://images.unsplash.com/photo-1489515217757-5fd1be406fef?auto=format&fit=crop&w=800&q=60',
    ),
    Dish(
      id: 'manty',
      name: 'Манты с тыквой',
      description: 'Тонкое тесто с сочной начинкой из тыквы и баранины.',
      categoryId: 'hot',
      price: 430,
      weight: 320,
      imageUrl:
          'https://images.unsplash.com/photo-1604908177035-2a9b7461c7d1?auto=format&fit=crop&w=800&q=60',
    ),
    Dish(
      id: 'dimlama',
      name: 'Дымлама',
      description: 'Тушёные овощи и мясо в собственном соку с ароматом специй.',
      categoryId: 'soups',
      price: 410,
      weight: 380,
      imageUrl:
          'https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=60',
    ),
    Dish(
      id: 'achik-chuchuk',
      name: 'Ачик-чучук',
      description: 'Свежий салат из помидоров, лука и ароматных трав.',
      categoryId: 'salads',
      price: 210,
      weight: 180,
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=60',
    ),
    Dish(
      id: 'sherbet',
      name: 'Шербет миндальный',
      description: 'Сливочный десерт с миндалём и нотками кардамона.',
      categoryId: 'desserts',
      price: 270,
      weight: 160,
      imageUrl:
          'https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=800&q=60',
    ),
    Dish(
      id: 'kompot',
      name: 'Компот из сухофруктов',
      description: 'Традиционный напиток с курагой, изюмом и яблоками.',
      categoryId: 'drinks',
      price: 120,
      weight: 350,
      imageUrl:
          'https://images.unsplash.com/photo-1580915411954-282cb1bd5390?auto=format&fit=crop&w=800&q=60',
    ),
  ];

  @override
  Future<List<Category>> loadCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _categories;
  }

  @override
  Future<List<Dish>> loadDishes() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _dishes;
  }

  @override
  Future<void> submitOrder(Order order) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? cancellationReason,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}

/// Example of how to wire a PHP/MySQL backend hosted on beget.com.
/// Replace the [MockBackendService] usage in [AppState] with an instance of
/// this class when REST endpoints are ready.
class PhpBackendService implements BackendService {
  PhpBackendService({required this.baseUrl, HttpClient? client})
      : client = client ?? HttpClient();

  final String baseUrl;
  final HttpClient client;

  @override
  Future<List<Category>> loadCategories() {
    throw UnimplementedError('Connect to your PHP API to load categories');
  }

  @override
  Future<List<Dish>> loadDishes() {
    throw UnimplementedError('Connect to your PHP API to load dishes');
  }

  @override
  Future<void> submitOrder(Order order) {
    throw UnimplementedError('POST order payload to your API');
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? cancellationReason,
  }) {
    throw UnimplementedError('PATCH order status via your API');
  }
}
