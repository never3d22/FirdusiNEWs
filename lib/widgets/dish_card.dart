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

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isCompact ? 26 : 32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isCompact ? 18 : 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isCompact ? 26 : 32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DishImage(
              dish: dish,
              isCompact: isCompact,
              onTap: () => _showDetails(context),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                isCompact ? 18 : 24,
                isCompact ? 16 : 22,
                isCompact ? 18 : 24,
                isCompact ? 18 : 22,
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
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      height: 1.4,
                    ),
                    maxLines: isCompact ? 3 : 4,
                    overflow:
                        isCompact ? TextOverflow.ellipsis : TextOverflow.visible,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _FeatureChip(
                        icon: Icons.scale_outlined,
                        label: '${dish.weight} г',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Стоимость',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.55),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dish.price.toStringAsFixed(0)} ₽',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) => ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                        child: quantity == 0
                            ? FilledButton.icon(
                                key: const ValueKey('add-button'),
                                onPressed: () => context.read<AppState>().addDish(dish),
                                icon: const Icon(Icons.add_circle_outline),
                                label: const Text('В корзину'),
                              )
                            : _QuantityControl(
                                key: ValueKey('quantity-$quantity'),
                                dish: dish,
                                quantity: quantity,
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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

class _DishImage extends StatelessWidget {
  const _DishImage({
    required this.dish,
    required this.isCompact,
    required this.onTap,
  });

  final Dish dish;
  final bool isCompact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(isCompact ? 26 : 32),
      ),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: const BoxDecoration(color: Colors.black12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Ink.image(
                image: NetworkImage(dish.imageUrl),
                fit: BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0),
                      Colors.black.withOpacity(0.45),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                bottom: 18,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: theme.colorScheme.primary.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Text(
                      '${dish.price.toStringAsFixed(0)} ₽',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DishDetails extends StatelessWidget {
  const _DishDetails({required this.dish});

  final Dish dish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final quantity = appState.cart[dish.id] ?? 0;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dish.name, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            dish.description,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FeatureChip(
                icon: Icons.scale_outlined,
                label: '${dish.weight} г',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Стоимость',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dish.price.toStringAsFixed(0)} ₽',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: child,
                ),
                child: quantity == 0
                    ? FilledButton(
                        key: const ValueKey('details-add-button'),
                        onPressed: () => context.read<AppState>().addDish(dish),
                        child: const Text('Добавить'),
                      )
                    : _QuantityControl(
                        key: ValueKey('details-quantity-$quantity'),
                        dish: dish,
                        quantity: quantity,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({super.key, required this.dish, required this.quantity});

  final Dish dish;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: theme.colorScheme.primary.withOpacity(0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded),
            onPressed: () => context.read<AppState>().decrementDish(dish.id),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$quantity',
              style: theme.textTheme.titleMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.read<AppState>().incrementDish(dish.id),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.primary.withOpacity(0.08),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
