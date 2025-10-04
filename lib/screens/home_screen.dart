import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/dish_card.dart';
import '../widgets/order_status_banner.dart';
import 'admin_login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final categories = appState.categories;
    final selectedCategories = appState.selectedCategoryIds;
    final restaurantInfo = appState.restaurantInfo;
    final filteredDishes = appState.filteredDishes;
    final selectedCategoryTitles = categories
        .where((category) => selectedCategories.contains(category.id))
        .map((category) => category.title)
        .toList();
    final filterLabel = selectedCategoryTitles.isEmpty
        ? 'Все категории'
        : selectedCategoryTitles.length == 1
            ? selectedCategoryTitles.first
            : 'Выбрано: ${selectedCategoryTitles.length}';

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFDF5F5), Color(0xFFFFFCF8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async => appState.initialize(),
        edgeOffset: 140,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 160,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(start: 24, bottom: 16),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      restaurantInfo.name.isNotEmpty ? restaurantInfo.name : 'Ресторан',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (restaurantInfo.workingHours.isNotEmpty)
                      Text(
                        restaurantInfo.workingHours,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                  ],
                ),
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9C2B31), Color(0xFFD96441)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurantInfo.name.isNotEmpty
                                ? 'Добро пожаловать в ${restaurantInfo.name}!'
                                : 'Добро пожаловать в ваш ресторан!'
                                    ' Настройте название в административной панели.',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Выбирайте категории, собирайте корзину и отслеживайте статус заказа в реальном времени.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.82),
                                ),
                          ),
                          if (restaurantInfo.workingHours.isNotEmpty ||
                              restaurantInfo.phone.isNotEmpty)
                            const SizedBox(height: 16),
                          if (restaurantInfo.workingHours.isNotEmpty ||
                              restaurantInfo.phone.isNotEmpty)
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                if (restaurantInfo.workingHours.isNotEmpty)
                                  _buildInfoChip(
                                    context,
                                    Icons.schedule_outlined,
                                    restaurantInfo.workingHours,
                                  ),
                                if (restaurantInfo.phone.isNotEmpty)
                                  _buildInfoChip(
                                    context,
                                    Icons.phone_outlined,
                                    restaurantInfo.phone,
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    icon: const Icon(Icons.admin_panel_settings_outlined),
                    color: Colors.white,
                    onPressed: () => Navigator.pushNamed(context, AdminLoginScreen.routeName),
                  ),
                ),
              ],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            const SliverToBoxAdapter(child: OrderStatusBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showCategoryFilterSheet(context),
                                icon: const Icon(Icons.filter_list_rounded),
                                label: Text(filterLabel),
                              ),
                            ),
                            if (selectedCategories.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: () => appState.clearCategoryFilter(),
                                child: const Text('Сбросить'),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              final isSelected = selectedCategories.contains(category.id);
                              return ChoiceChip(
                                label: Text(category.title),
                                selected: isSelected,
                                onSelected: (_) =>
                                    context.read<AppState>().selectCategory(category.id),
                              );
                            },
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemCount: categories.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  int crossAxisCount;
                  if (width >= 1200) {
                    crossAxisCount = 4;
                  } else if (width >= 900) {
                    crossAxisCount = 3;
                  } else if (width >= 360) {
                    crossAxisCount = 2;
                  } else {
                    crossAxisCount = 1;
                  }
                  if (crossAxisCount == 1) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => DishCard(dish: filteredDishes[index]),
                        childCount: filteredDishes.length,
                      ),
                    );
                  }
                  final aspectRatio = crossAxisCount >= 3 ? 0.82 : 0.72;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: aspectRatio,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return DishCard(
                          dish: filteredDishes[index],
                          margin: EdgeInsets.zero,
                        );
                      },
                      childCount: filteredDishes.length,
                    ),
                  );
                },
              ),
            ),
            if (filteredDishes.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('В выбранной категории пока нет доступных блюд.'),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}

void _showCategoryFilterSheet(BuildContext context) async {
  final appState = context.read<AppState>();
  final categories = appState.categories;
  final initiallySelected = Set<String>.from(appState.selectedCategoryIds);
  final result = await showModalBottomSheet<Set<String>>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final theme = Theme.of(context);
      final localSelected = Set<String>.from(initiallySelected);
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Фильтр по категориям',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.5,
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        CheckboxListTile(
                          value: localSelected.isEmpty,
                          onChanged: (_) {
                            setState(() => localSelected.clear());
                          },
                          title: const Text('Все категории'),
                        ),
                        ...categories.map(
                          (category) => CheckboxListTile(
                            value: localSelected.contains(category.id),
                            onChanged: (value) {
                              setState(() {
                                if (value ?? false) {
                                  localSelected.add(category.id);
                                } else {
                                  localSelected.remove(category.id);
                                }
                              });
                            },
                            title: Text(category.title),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() => localSelected.clear());
                          },
                          child: const Text('Очистить'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pop(context, Set<String>.from(localSelected));
                          },
                          child: const Text('Применить'),
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
    },
  );

  if (result != null) {
    if (result.isEmpty) {
      appState.clearCategoryFilter();
    } else {
      appState.setCategoryFilter(result);
    }
  }
}

Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
  return DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.14),
      borderRadius: BorderRadius.circular(24),
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
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}
