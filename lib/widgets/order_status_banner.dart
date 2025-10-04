import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/models/order.dart';
import '../providers/app_state.dart';

class OrderStatusBanner extends StatelessWidget {
  const OrderStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final order = context.select<AppState, Order?>((state) => state.activeOrder);
    if (order == null) {
      return const SizedBox.shrink();
    }

    final statusText = _statusLabel(order.status);
    final dateFormat = DateFormat('dd MMM HH:mm');
    final theme = Theme.of(context);
    final locationText = order.mode == DeliveryMode.pickup
        ? (order.address.isNotEmpty ? 'Самовывоз · ${order.address}' : 'Самовывоз')
        : (order.address.isNotEmpty ? order.address : 'Адрес не указан');
    final intervalText = order.deliveryInterval;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ваш заказ в пути',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '№ ${order.id} · $statusText · ${dateFormat.format(order.createdAt)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.86),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Сумма: ${order.total.toStringAsFixed(0)} ₽ · $locationText',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.86),
                ),
              ),
              if (intervalText != null && intervalText.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Интервал: $intervalText',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.86),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Ожидает подтверждения';
      case OrderStatus.accepted:
        return 'Принят';
      case OrderStatus.cooking:
        return 'Готовится';
      case OrderStatus.delivering:
        return 'Доставляется';
      case OrderStatus.completed:
        return 'Завершен';
      case OrderStatus.cancelled:
        return 'Отменен';
    }
  }
}
