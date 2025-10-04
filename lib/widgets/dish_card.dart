import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/dish.dart';
import '../providers/app_state.dart';

class DishCard extends StatelessWidget {
  const DishCard({super.key, required this.dish, this.margin});

  final Dish dish;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final quantity = appState.cart[dish.id] ?? 0;

    if (dish.isHidden) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final isCompact = margin == EdgeInsets.zero;
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      clipBehavior: Clip.antiAlias,
      elevation: isCompact ? 3 : 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isCompact ? 20 : 28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Ink.image(
                  image: NetworkImage(dish.imageUrl),
                  fit: BoxFit.cover,
                  child: InkWell(onTap: () => _showDetails(context)),
                ),
                Positioned(
                  right: 16,
                  top: 16,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        '${dish.weight} г',
                        style: theme.textTheme.labelMedium?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              isCompact ? 16 : 20,
              isCompact ? 14 : 18,
              isCompact ? 16 : 20,
              isCompact ? 12 : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  dish.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.72),
                  ),
                  maxLines: isCompact ? 3 : null,
                  overflow:
                      isCompact ? TextOverflow.ellipsis : TextOverflow.visible,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.scale_outlined,
                      size: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${dish.weight} г',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${dish.price.toStringAsFixed(0)} ₽',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    quantity == 0
                        ? FilledButton.icon(
                            onPressed: () => context.read<AppState>().addDish(dish),
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Добавить'),
                          )
                        : _QuantityControl(dish: dish, quantity: quantity),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => _DishDetails(dish: dish),
    );
  }
}

class _DishDetails extends StatelessWidget {
  const _DishDetails({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final quantity = appState.cart[dish.id] ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dish.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(dish.description),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dish.price.toStringAsFixed(0)} ₽',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${dish.weight} г',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              quantity == 0
                  ? FilledButton(
                      onPressed: () => context.read<AppState>().addDish(dish),
                      child: const Text('Добавить'),
                    )
                  : _QuantityControl(dish: dish, quantity: quantity),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({required this.dish, required this.quantity});

  final Dish dish;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => context.read<AppState>().decrementDish(dish.id),
          ),
          Text('$quantity', style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.read<AppState>().incrementDish(dish.id),
          ),
        ],
      ),
    );
  }
}
