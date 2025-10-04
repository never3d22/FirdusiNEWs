import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/restaurant_info.dart';
import '../providers/app_state.dart';
import '../widgets/dish_card.dart';
import '../widgets/order_status_banner.dart';
import 'admin_login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final theme = Theme.of(context);
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
    final hasSelections = selectedCategories.isNotEmpty;

    return Stack(
      children: [
        const _HomeBackground(),
        RefreshIndicator(
          onRefresh: () async => appState.initialize(),
          edgeOffset: 180,
          displacement: 16,
          color: theme.colorScheme.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                expandedHeight: 220,
                automaticallyImplyLeading: false,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final progress = ((constraints.maxHeight - kToolbarHeight) /
                            (220 - kToolbarHeight))
                        .clamp(0.0, 1.0);
                    final collapsedOpacity = 1 - progress;
                    final displayName = restaurantInfo.name.isNotEmpty
                        ? restaurantInfo.name
                        : 'Ресторан';
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          titlePadding:
                              const EdgeInsetsDirectional.only(start: 24, bottom: 16),
                          title: Opacity(
                            opacity: collapsedOpacity.clamp(0.0, 1.0),
                            child: Text(
                              displayName,
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                          background: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
                            child: _HeroHeader(info: restaurantInfo, progress: progress),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.15),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.admin_panel_settings_outlined),
                        color: theme.colorScheme.primary,
                        onPressed: () =>
                            Navigator.pushNamed(context, AdminLoginScreen.routeName),
                      ),
                    ),
                  ),
                ],
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              const SliverToBoxAdapter(child: OrderStatusBanner()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: _GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonalIcon(
                                onPressed: () => _showCategoryFilterSheet(context),
                                icon: const Icon(Icons.tune_rounded),
                                label: Text(filterLabel),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            if (hasSelections) ...[
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: () => appState.clearCategoryFilter(),
                                child: const Text('Сбросить'),
                              ),
                            ],
                          ],
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: hasSelections
                              ? Padding(
                                  key: const ValueKey('selected-categories'),
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: selectedCategoryTitles
                                        .map(
                                          (title) => Chip(
                                            label: Text(title),
                                            avatar: Icon(
                                              Icons.check_circle,
                                              size: 18,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 20),
                        if (categories.isEmpty)
                          Text(
                            'Категории появятся после настройки меню в административной панели.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                          )
                        else
                          SizedBox(
                            height: 52,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                final isSelected =
                                    selectedCategories.contains(category.id);
                                return FilterChip(
                                  label: Text(category.title),
                                  selected: isSelected,
                                  onSelected: (_) =>
                                      context.read<AppState>().selectCategory(category.id),
                                );
                              },
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemCount: categories.length,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    final aspectRatio = crossAxisCount >= 3 ? 0.8 : 0.74;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 40, 32, 80),
                    child: _GlassPanel(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'В выбранной категории пока нет блюд',
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Снимите фильтр или загляните позже — команда уже работает над новинками.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ],
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
                    style:
                        theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.55,
                    ),
                    child: Material(
                      color: Colors.transparent,
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
                          const Divider(),
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

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(28);
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Colors.white.withOpacity(0.72),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF4ED), Color(0xFFFFFBF8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              _BlurOrb(
                color: scheme.primary.withOpacity(0.25),
                size: 240,
                top: -60,
                left: -80,
              ),
              _BlurOrb(
                color: scheme.secondary.withOpacity(0.18),
                size: 200,
                top: 140,
                right: -60,
              ),
              _BlurOrb(
                color: scheme.primaryContainer.withOpacity(0.2),
                size: 280,
                bottom: -140,
                left: -40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({
    required this.color,
    required this.size,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  final Color color;
  final double size;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withOpacity(0.01),
            ],
            stops: const [0.1, 1],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.info, required this.progress});

  final RestaurantInfo info;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = info.name.isNotEmpty ? info.name : 'ваш ресторан';
    final workingHours = info.workingHours.isNotEmpty ? info.workingHours : null;
    final phone = info.phone.isNotEmpty ? info.phone : null;
    final overlay = 0.18 + progress * 0.2;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.25),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -40,
            child: _OrnamentCircle(
              size: 160,
              color: Colors.white.withOpacity(overlay),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -20,
            child: _OrnamentCircle(
              size: 200,
              color: Colors.white.withOpacity(overlay * 0.8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14 + progress * 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Авторская кухня',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Добро пожаловать в ${name.isNotEmpty ? name : 'Firdusi Food'}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Выбирайте блюда, вдохновленные восточными традициями и современными гастротрендами.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
                if (workingHours != null || phone != null) ...[
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (workingHours != null)
                        _HeaderInfoChip(
                          icon: Icons.schedule_outlined,
                          label: workingHours,
                        ),
                      if (phone != null)
                        _HeaderInfoChip(
                          icon: Icons.phone_in_talk_outlined,
                          label: phone,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrnamentCircle extends StatelessWidget {
  const _OrnamentCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.01),
          ],
          stops: const [0.1, 1],
        ),
      ),
    );
  }
}

class _HeaderInfoChip extends StatelessWidget {
  const _HeaderInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(22),
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
              style: theme.textTheme.bodyMedium?.copyWith(
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
