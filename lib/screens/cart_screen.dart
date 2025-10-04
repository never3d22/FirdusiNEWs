import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/dish.dart';
import '../data/models/order.dart';
import '../data/models/restaurant_info.dart';
import '../providers/app_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _addressController = TextEditingController(text: appState.customAddress);
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final cartEntries = appState.cart.entries.toList();
    final validItems = <MapEntry<Dish, int>>[];
    var hasMissingDishes = false;
    final timeSlots = appState.availableTimeSlotsForMode(appState.deliveryMode);
    final selectedSlot = appState.selectedTimeSlotForMode(appState.deliveryMode);

    for (final entry in cartEntries) {
      final dish = appState.dishes.cast<Dish?>().firstWhere(
            (d) => d?.id == entry.key,
            orElse: () => null,
          );
      if (dish == null || dish.isHidden) {
        hasMissingDishes = true;
        continue;
      }
      validItems.add(MapEntry(dish, entry.value));
    }

    if (hasMissingDishes) {
      scheduleMicrotask(() {
        appState.removeInvalidCartItems();
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Корзина')),
      body: cartEntries.isEmpty
          ? const Center(child: Text('Добавьте блюда из меню'))
          : DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFDF5F5), Color(0xFFFFFCF8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    _CartSection(
                      title: 'Ваши блюда',
                      child: Column(
                        children: validItems.map((entry) {
                          final dish = entry.key;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    dish.imageUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dish.name,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${dish.weight} г',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium
                                            ?.copyWith(color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: () => appState.decrementDish(dish.id),
                                      ),
                                      Text(
                                        '${entry.value}',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: () => appState.incrementDish(dish.id),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _CartSection(
                      title: 'Получение заказа',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ToggleButtons(
                            isSelected: [
                              appState.deliveryMode == DeliveryMode.pickup,
                              appState.deliveryMode == DeliveryMode.delivery,
                            ],
                            borderRadius: BorderRadius.circular(18),
                            selectedColor: Theme.of(context).colorScheme.primary,
                            fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                            onPressed: (index) {
                              final mode = index == 0 ? DeliveryMode.pickup : DeliveryMode.delivery;
                              appState.setDeliveryMode(mode);
                            },
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [Icon(Icons.store), SizedBox(width: 8), Text('Самовывоз')],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [Icon(Icons.delivery_dining), SizedBox(width: 8), Text('Доставка')],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (appState.deliveryMode == DeliveryMode.pickup) ...[
                            _PickupInfoCard(info: appState.restaurantInfo),
                            const SizedBox(height: 16),
                          ],
                          if (appState.deliveryMode == DeliveryMode.delivery)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _addressController,
                                  decoration: const InputDecoration(labelText: 'Адрес доставки'),
                                  onChanged: appState.setCustomAddress,
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.my_location),
                                  label: const Text('Использовать геолокацию'),
                                ),
                              ],
                            ),
                          if (appState.deliveryMode == DeliveryMode.delivery)
                            const SizedBox(height: 16),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.phone_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: const Text('Телефон для связи'),
                            subtitle: Text(
                              appState.phone.isNotEmpty
                                  ? appState.phone
                                  : 'Будет указан при оформлении заказа',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _TimeSlotSelector(
                            mode: appState.deliveryMode,
                            slots: timeSlots,
                            selected: selectedSlot,
                            onChanged: (value) => appState
                                .setSelectedTimeSlotForMode(appState.deliveryMode, value),
                          ),
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Добавить приборы'),
                            subtitle: Text(
                              appState.utensilsEnabled
                                  ? 'По умолчанию 1 комплект'
                                  : 'Приборы не требуются',
                            ),
                            value: appState.utensilsEnabled,
                            onChanged: (value) {
                              if (value != null) {
                                appState.setUtensilsEnabled(value);
                              }
                            },
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: appState.utensilsEnabled
                                ? _UtensilsStepper(
                                    key: const ValueKey('utensils-stepper'),
                                    count: appState.utensilsCount,
                                    max: appState.maxUtensilsCount,
                                    onChanged: appState.setUtensilsCount,
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _CartSection(
                      title: 'Оплата',
                      child: Column(
                        children: PaymentMethod.values
                            .map(
                              (method) => RadioListTile<PaymentMethod>(
                                value: method,
                                groupValue: appState.paymentMethod,
                                onChanged: (value) {
                                  if (value != null) appState.setPaymentMethod(value);
                                },
                                title: Text(_paymentLabel(method)),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _CartSection(
                      title: 'Итого',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Сумма заказа',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.black54),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${appState.cartTotal.toStringAsFixed(0)} ₽',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                          FilledButton(
                            onPressed:
                                appState.cart.isEmpty ? null : () => _handleCheckout(context),
                            child: const Text('Оформить заказ'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _paymentLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return 'Наличные';
      case PaymentMethod.cardCourier:
        return 'Картой курьеру';
      case PaymentMethod.cardOnline:
        return 'Онлайн-оплата';
    }
  }

  Future<void> _handleCheckout(BuildContext context) async {
    final appState = context.read<AppState>();
    final controller = TextEditingController(text: appState.phone);
    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Контакт для подтверждения заказа',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Укажите номер телефона, чтобы мы могли связаться с вами при необходимости.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Номер телефона',
                    hintText: '+7 (___) ___-__-__',
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Введите номер телефона' : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Отмена'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            Navigator.pop(context, controller.text.trim());
                          }
                        },
                        child: const Text('Продолжить'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    controller.dispose();

    final normalized = result?.trim();
    if (normalized == null || normalized.isEmpty) {
      return;
    }

    appState.setPhone(normalized);
    await appState.checkout();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Заказ оформлен')),
    );
  }
}

class _CartSection extends StatelessWidget {
  const _CartSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _UtensilsStepper extends StatelessWidget {
  const _UtensilsStepper({
    super.key,
    required this.count,
    required this.max,
    required this.onChanged,
  });

  final int count;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayCount = count.clamp(0, max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Количество приборов',
          style:
              theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: theme.colorScheme.primary.withOpacity(0.08),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: displayCount > 0
                        ? () => onChanged(displayCount - 1)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '$displayCount',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: displayCount < max
                        ? () => onChanged(displayCount + 1)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'до $max',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimeSlotSelector extends StatelessWidget {
  const _TimeSlotSelector({
    super.key,
    required this.mode,
    required this.slots,
    required this.selected,
    required this.onChanged,
  });

  final DeliveryMode mode;
  final List<String> slots;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modeLabel = mode == DeliveryMode.pickup ? 'самовывоза' : 'доставки';
    final currentLabel = selected ?? 'Сейчас';

    if (slots.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Интервал $modeLabel',
            style: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Свободных интервалов нет. Мы уточним время дополнительно.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Интервал $modeLabel',
          style:
              theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _openSlotPicker(context),
                icon: const Icon(Icons.schedule_rounded),
                label: Text(currentLabel),
              ),
            ),
            if (selected != null) ...[
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => onChanged(null),
                child: const Text('Сейчас'),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _openSlotPicker(BuildContext context) async {
    final theme = Theme.of(context);
    final result = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выберите интервал',
                  style:
                      theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.55,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.flash_on_outlined),
                        title: const Text('Сейчас'),
                        subtitle: const Text('Как только заказ будет готов'),
                        selected: selected == null,
                        onTap: () => Navigator.pop(context, ''),
                      ),
                      const Divider(),
                      ...slots.map(
                        (slot) => ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(slot),
                          selected: selected == slot,
                          onTap: () => Navigator.pop(context, slot),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Закрыть'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result == null) {
      return;
    }
    if (result.isEmpty) {
      onChanged(null);
    } else {
      onChanged(result);
    }
  }
}

class _PickupInfoCard extends StatelessWidget {
  const _PickupInfoCard({super.key, required this.info});

  final RestaurantInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final address = info.address.isNotEmpty ? info.address : 'Адрес не указан';
    final hours = info.workingHours.isNotEmpty ? info.workingHours : null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.store_mall_directory_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Пункт самовывоза',
                style: theme.textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          if (hours != null) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.schedule_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Время работы: $hours',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
