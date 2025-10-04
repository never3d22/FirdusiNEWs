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
    final statusIcon = _statusIcon(order.status);
    final progress = _statusProgress(order.status);
    final dateFormat = DateFormat('dd MMM HH:mm');
    final theme = Theme.of(context);
    final locationText = order.mode == DeliveryMode.pickup
        ? (order.address.isNotEmpty ? 'Самовывоз · ${order.address}' : 'Самовывоз')
        : (order.address.isNotEmpty ? order.address : 'Адрес не указан');
    final intervalText = order.deliveryInterval;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(opacity: value, child: child),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.2),
                blurRadius: 26,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white.withOpacity(0.16),
                      child: Icon(statusIcon, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ваш заказ в пути',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '№ ${order.id} · $statusText · ${dateFormat.format(order.createdAt)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _StatusChip(
                      icon: Icons.receipt_long_outlined,
                      label: 'Сумма: ${order.total.toStringAsFixed(0)} ₽',
                    ),
                    _StatusChip(
                      icon: Icons.place_outlined,
                      label: locationText,
                    ),
                    if (intervalText != null && intervalText.isNotEmpty)
                      _StatusChip(
                        icon: Icons.access_time,
                        label: 'Интервал: $intervalText',
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
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

  IconData _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.watch_later_outlined;
      case OrderStatus.accepted:
        return Icons.how_to_reg_outlined;
      case OrderStatus.cooking:
        return Icons.local_fire_department_outlined;
      case OrderStatus.delivering:
        return Icons.delivery_dining;
      case OrderStatus.completed:
        return Icons.emoji_events_outlined;
      case OrderStatus.cancelled:
        return Icons.block_outlined;
    }
  }

  double _statusProgress(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0.2;
      case OrderStatus.accepted:
        return 0.4;
      case OrderStatus.cooking:
        return 0.6;
      case OrderStatus.delivering:
        return 0.85;
      case OrderStatus.completed:
        return 1.0;
      case OrderStatus.cancelled:
        return 1.0;
    }
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
