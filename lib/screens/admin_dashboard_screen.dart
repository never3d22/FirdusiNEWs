import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/admin_user.dart';
import '../data/models/category.dart';
import '../data/models/dish.dart';
import '../data/models/order.dart';
import '../data/models/restaurant_info.dart';
import '../data/models/restaurant_settings.dart';
import '../providers/app_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  static const routeName = '/admin-dashboard';

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late TimeOfDay _openingTime;
  late TimeOfDay _closingTime;
  RestaurantInfo? _lastInfo;
  bool _isSaving = false;
  OrderStatus? _statusFilter;
  String? _userFilter;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _openingTime = const TimeOfDay(hour: 10, minute: 0);
    _closingTime = const TimeOfDay(hour: 22, minute: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final info = context.watch<AppState>().restaurantInfo;
    if (_lastInfo != info) {
      _lastInfo = info;
      _nameController.text = info.name;
      _addressController.text = info.address;
      _phoneController.text = info.phone;
      final times = _parseWorkingHours(info.workingHours);
      if (times != null) {
        _openingTime = times[0];
        _closingTime = times[1];
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.isAdminAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Админ-панель')),
        body: const Center(
          child: Text('Авторизуйтесь, чтобы управлять рестораном.'),
        ),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Админ-панель'),
          actions: [
            IconButton(
              tooltip: 'Выйти из админ-панели',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await context.read<AppState>().signOutAdmin();
                if (!mounted) return;
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
            IconButton(
              tooltip: 'Вернуться в приложение',
              icon: const Icon(Icons.exit_to_app),
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            )
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Заказы'),
              Tab(text: 'Категории'),
              Tab(text: 'Блюда'),
              Tab(text: 'Пользователи'),
              Tab(text: 'Ресторан'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersTab(context),
            _buildCategoriesTab(context),
            _buildDishesTab(context),
            _buildUsersTab(context),
            _buildSettingsTab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _buildSettingsCard(context),
      ],
    );
  }

  Widget _buildCategoriesTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _buildCategoriesCard(context),
      ],
    );
  }

  Widget _buildDishesTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        _buildDishesCard(context),
      ],
    );
  }

  Widget _buildUsersTab(BuildContext context) {
    final appState = context.watch<AppState>();
    final users = appState.adminUsers;
    final totalOrders = users.fold<int>(0, (sum, user) => sum + user.orderCount);
    final blockedCount = users.where((user) => user.isBlocked).length;
    final activeUsers = users.where((user) => user.isActive).length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildSummaryChip(
                  context,
                  icon: Icons.people_outline,
                  label: 'Всего пользователей',
                  value: users.length.toString(),
                ),
                _buildSummaryChip(
                  context,
                  icon: Icons.receipt_long,
                  label: 'Всего заказов',
                  value: totalOrders.toString(),
                ),
                _buildSummaryChip(
                  context,
                  icon: Icons.no_accounts,
                  label: 'Заблокировано',
                  value: blockedCount.toString(),
                ),
                _buildSummaryChip(
                  context,
                  icon: Icons.online_prediction,
                  label: 'Сейчас в приложении',
                  value: activeUsers.toString(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (users.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Пока нет данных о пользователях. Оформите тестовый заказ или добавьте клиента.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          ...users.map((user) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildUserCard(context, user),
              )),
      ],
    );
  }

  Widget _buildOrdersTab(BuildContext context) {
    final appState = context.watch<AppState>();
    final orders = appState.adminOrders;
    final users = appState.adminUsers;
    final filtered = orders.where((order) {
      final matchesStatus =
          _statusFilter == null || order.status == _statusFilter;
      final normalizedPhone = appState.normalizedPhone(order.phone);
      final orderUserId =
          normalizedPhone.isNotEmpty ? normalizedPhone : 'guest-${order.id}';
      final matchesUser =
          _userFilter == null || orderUserId == _userFilter;
      return matchesStatus && matchesUser;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Фильтры',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: 220,
                      child: DropdownButtonFormField<OrderStatus?>(
                        value: _statusFilter,
                        decoration: const InputDecoration(
                          labelText: 'Статус заказа',
                        ),
                        items: [
                          const DropdownMenuItem<OrderStatus?>(
                            value: null,
                            child: Text('Все статусы'),
                          ),
                          ...OrderStatus.values.map(
                            (status) => DropdownMenuItem<OrderStatus?>(
                              value: status,
                              child: Text(_statusLabel(status)),
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(() => _statusFilter = value),
                      ),
                    ),
                    SizedBox(
                      width: 280,
                      child: DropdownButtonFormField<String?>(
                        value: _userFilter,
                        decoration: const InputDecoration(
                          labelText: 'Пользователь',
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Все пользователи'),
                          ),
                          ...users.map(
                            (user) => DropdownMenuItem<String?>(
                              value: user.phone,
                              child: Text(
                                user.displayName != user.fallbackPhone
                                    ? '${user.displayName} (${user.fallbackPhone})'
                                    : user.fallbackPhone,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(() => _userFilter = value),
                      ),
                    ),
                    if (_statusFilter != null || _userFilter != null)
                      OutlinedButton.icon(
                        onPressed: () => setState(() {
                          _statusFilter = null;
                          _userFilter = null;
                        }),
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Сбросить фильтры'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Заказы по выбранным параметрам не найдены.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          )
        else
          ...filtered.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildOrderCard(context, order),
            ),
          ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Информация о ресторане',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название',
                  hintText: 'Например, Firdusi',
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Укажите название ресторана';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Адрес',
                  hintText: 'г. Душанбе, ул. Фирдуоси, 1',
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Укажите адрес ресторана';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TimePickerField(
                      label: 'Начало работы',
                      value: _formatTime(_openingTime),
                      onTap: () => _selectTime(context, isOpening: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimePickerField(
                      label: 'Окончание работы',
                      value: _formatTime(_closingTime),
                      onTap: () => _selectTime(context, isOpening: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  hintText: '+7 (___) ___-__-__',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите контактный телефон';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _handleSave,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isSaving
                        ? const SizedBox(
                            key: ValueKey('progress'),
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(
                            Icons.save_outlined,
                            key: ValueKey('icon'),
                          ),
                  ),
                  label: Text(_isSaving ? 'Сохранение…' : 'Сохранить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesCard(BuildContext context) {
    final appState = context.watch<AppState>();
    final categories = appState.categories;
    final dishes = appState.dishes;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Категории меню', style: theme.textTheme.titleMedium),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _showCategoryDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (categories.isEmpty)
              Text(
                'Создайте первую категорию, чтобы сгруппировать блюда.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                onReorder: (oldIndex, newIndex) =>
                    context.read<AppState>().reorderCategories(oldIndex, newIndex),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final count = dishes.where((dish) => dish.categoryId == category.id).length;
                  return ListTile(
                    key: ValueKey(category.id),
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_handle),
                    ),
                    title: Text(category.title),
                    subtitle: Text('Блюд: $count'),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          tooltip: 'Переименовать',
                          onPressed: () => _showCategoryDialog(category: category),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Удалить',
                          onPressed: () => _confirmDeleteCategory(category),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishesCard(BuildContext context) {
    final appState = context.watch<AppState>();
    final dishes = appState.dishes;
    final categories = appState.categories;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Блюда меню', style: theme.textTheme.titleMedium),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () => _showDishDialog(),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Новое блюдо'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (dishes.isEmpty)
              Text(
                'Загрузите меню или добавьте блюда через административную панель.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Название')),
                    DataColumn(label: Text('Категория')),
                    DataColumn(label: Text('Цена')),
                    DataColumn(label: Text('Вес')),
                    DataColumn(label: Text('Статус')),
                    DataColumn(label: Text('Действия')),
                  ],
                  rows: dishes.map((dish) {
                    final categoryName = _categoryTitle(categories, dish.categoryId);
                    return DataRow(
                      color: dish.isHidden
                          ? MaterialStatePropertyAll(
                              Theme.of(context)
                                  .colorScheme
                                  .surfaceVariant
                                  .withOpacity(0.4),
                            )
                          : null,
                      cells: [
                        DataCell(Text(dish.name)),
                        DataCell(Text(categoryName)),
                        DataCell(Text('${dish.price.toStringAsFixed(0)} ₽')),
                        DataCell(Text('${dish.weight} г')),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: !dish.isHidden,
                                onChanged: (_) =>
                                    context.read<AppState>().toggleDishHidden(dish.id),
                              ),
                              const SizedBox(width: 8),
                              Text(dish.isHidden ? 'Скрыто' : 'Видно'),
                            ],
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                tooltip: 'Редактировать',
                                onPressed: () => _showDishDialog(dish: dish),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: 'Удалить',
                                onPressed: () => _confirmDeleteDish(dish),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    final theme = Theme.of(context);
    final isCancelled = order.status == OrderStatus.cancelled;
    final statusOptions = OrderStatus.values
        .where((status) => status != OrderStatus.cancelled)
        .toList();
    final nextStatus = _nextStatus(order.status, statusOptions);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Заказ №${order.id}',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Создан: ${_formatOrderDate(order.createdAt)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                Chip(
                  label: Text(
                    _statusLabel(order.status),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  backgroundColor: _statusColor(theme, order.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Клиент: ${order.customerName.isEmpty ? 'Не указан' : order.customerName}'),
            Text('Телефон: ${order.phone.isEmpty ? 'Не указан' : order.phone}'),
            Text('Адрес: ${order.address.isEmpty ? 'Самовывоз' : order.address}'),
            Text('Приборы: ${order.utensilsCount}'),
            Text(
              'Интервал: ${order.deliveryInterval == null || order.deliveryInterval!.isEmpty ? 'По готовности' : order.deliveryInterval}',
            ),
            const SizedBox(height: 12),
            if (!isCancelled)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 168, minHeight: 48),
                    child: FilledButton(
                      onPressed: nextStatus == null
                          ? null
                          : () {
                              final upcoming =
                                  _nextStatus(order.status, statusOptions);
                              if (upcoming != null) {
                                context
                                    .read<AppState>()
                                    .updateOrderStatus(order.id, upcoming);
                              }
                            },
                      child: Text(
                        nextStatus == null
                            ? 'Статус завершён'
                            : 'Следующий: ${_statusLabel(nextStatus)}',
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: () => _promptCancelOrder(context, order),
                    icon: const Icon(Icons.cancel_schedule_send_outlined),
                    label: const Text('Отменить заказ'),
                  ),
                ],
              ),
            if (isCancelled)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Заказ отменен',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.cancellationReason?.isNotEmpty == true
                                ? order.cancellationReason!
                                : 'Причина не указана',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(height: 20),
            ...order.items.map(
              (item) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(item.dishName),
                trailing: Text('${item.quantity} × ${item.dishPrice.toStringAsFixed(0)} ₽'),
              ),
            ),
            const Divider(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Итого: ${order.total.toStringAsFixed(0)} ₽',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _promptCancelOrder(BuildContext context, Order order) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Отменить заказ №${order.id}'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Причина отмены',
                hintText: 'Например, клиент попросил перенести заказ',
              ),
              minLines: 2,
              maxLines: 4,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Укажите причину отмены' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Назад'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, controller.text.trim());
                }
              },
              child: const Text('Подтвердить'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    final trimmed = reason?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return;
    }
    await context.read<AppState>().cancelOrder(order.id, trimmed);
  }

  Color _statusColor(ThemeData theme, OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return theme.colorScheme.primary.withOpacity(0.45);
      case OrderStatus.accepted:
        return theme.colorScheme.secondary.withOpacity(0.55);
      case OrderStatus.cooking:
        return Colors.orangeAccent.withOpacity(0.6);
      case OrderStatus.delivering:
        return Colors.blueAccent.withOpacity(0.6);
      case OrderStatus.completed:
        return Colors.green.withOpacity(0.6);
      case OrderStatus.cancelled:
        return theme.colorScheme.error.withOpacity(0.6);
    }
  }

  Widget _buildUserCard(BuildContext context, AdminUser user) {
    final theme = Theme.of(context);
    final chips = <Widget>[];
    if (user.isActive) {
      chips.add(
        Chip(
          label: const Text('Активен сейчас'),
          avatar: const Icon(Icons.radio_button_checked, size: 16),
          backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
        ),
      );
    }
    if (user.isBlocked) {
      chips.add(
        Chip(
          label: const Text('Заблокирован'),
          avatar: const Icon(Icons.block, size: 16),
          backgroundColor: theme.colorScheme.error.withOpacity(0.18),
        ),
      );
    }

    final totalSpent = user.totalSpent.toStringAsFixed(0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName.characters.first.toUpperCase()
                        : '?',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Телефон: ${user.fallbackPhone}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (user.profile.addresses.isNotEmpty)
                        Text(
                          'Адрес: ${user.profile.addresses.first}',
                          style: theme.textTheme.bodySmall,
                        ),
                      if (chips.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: chips,
                        ),
                      ],
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
                _buildSummaryChip(
                  context,
                  icon: Icons.shopping_bag_outlined,
                  label: 'Заказов',
                  value: user.orderCount.toString(),
                ),
                _buildSummaryChip(
                  context,
                  icon: Icons.payments_outlined,
                  label: 'Сумма заказов',
                  value: '$totalSpent ₽',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: user.orderCount == 0
                      ? null
                      : () => _showUserOrders(user),
                  icon: const Icon(Icons.receipt_long),
                  label: const Text('Заказы пользователя'),
                ),
                OutlinedButton.icon(
                  onPressed: user.canBeBlocked
                      ? () => context.read<AppState>().toggleUserBlocked(user.phone)
                      : null,
                  icon: Icon(user.isBlocked ? Icons.lock_open : Icons.lock_outline),
                  label: Text(user.isBlocked ? 'Разблокировать' : 'Заблокировать'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 18, color: theme.colorScheme.primary),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium,
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final openMinutes = _openingTime.hour * 60 + _openingTime.minute;
    final closeMinutes = _closingTime.hour * 60 + _closingTime.minute;
    if (closeMinutes <= openMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Время закрытия должно быть позже времени открытия')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
    });
    final settings = RestaurantSettings(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      workingHours: '${_formatTime(_openingTime)} – ${_formatTime(_closingTime)}',
      phone: _phoneController.text.trim(),
    );
    await context.read<AppState>().updateRestaurantSettings(settings);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Данные ресторана обновлены')),
    );
  }

  Future<void> _showCategoryDialog({Category? category}) async {
    final controller = TextEditingController(text: category?.title ?? '');
    final formKey = GlobalKey<FormState>();
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(category == null ? 'Новая категория' : 'Редактирование категории'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Название категории'),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Введите название категории';
                  }
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop(true);
                  }
                },
                child: Text(category == null ? 'Создать' : 'Сохранить'),
              ),
            ],
          );
        },
      );
      if (confirmed == true) {
        final trimmed = controller.text.trim();
        if (category == null) {
          await context.read<AppState>().addCategory(trimmed);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Категория "$trimmed" добавлена')),
          );
        } else {
          await context.read<AppState>().updateCategoryTitle(category.id, trimmed);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Категория обновлена')),
          );
        }
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _confirmDeleteCategory(Category category) async {
    final appState = context.read<AppState>();
    if (appState.hasDishesInCategory(category.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала перенесите или удалите блюда из этой категории.'),
        ),
      );
      return;
    }
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить категорию?'),
          content: Text('Категория "${category.title}" будет удалена без возможности восстановления.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
    if (shouldDelete == true) {
      await appState.removeCategory(category.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Категория "${category.title}" удалена')),
      );
    }
  }

  Future<void> _showDishDialog({Dish? dish}) async {
    final appState = context.read<AppState>();
    final categories = appState.categories;
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала создайте хотя бы одну категорию.')),
      );
      return;
    }
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: dish?.name ?? '');
    final descriptionController = TextEditingController(text: dish?.description ?? '');
    final priceController = TextEditingController(
      text: (dish?.price ?? 0)
          .toStringAsFixed((dish?.price ?? 0).truncateToDouble() == (dish?.price ?? 0) ? 0 : 2),
    );
    final weightController = TextEditingController(text: (dish?.weight ?? 0).toString());
    final imageController = TextEditingController(text: dish?.imageUrl ?? '');
    var selectedCategoryId = dish?.categoryId ?? categories.first.id;
    var isVisible = dish == null ? true : !dish.isHidden;

    try {
      final result = await showDialog<_DishEditorResult>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(dish == null ? 'Новое блюдо' : 'Редактирование блюда'),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Название'),
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введите название блюда';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: descriptionController,
                          decoration: const InputDecoration(labelText: 'Описание'),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: selectedCategoryId,
                          decoration: const InputDecoration(labelText: 'Категория'),
                          items: categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category.id,
                                  child: Text(category.title),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => selectedCategoryId = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: priceController,
                          decoration: const InputDecoration(labelText: 'Цена, ₽'),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true, signed: false),
                          validator: (value) {
                            final normalized = value?.replaceAll(',', '.');
                            final price = double.tryParse(normalized ?? '');
                            if (price == null || price <= 0) {
                              return 'Введите корректную цену';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: weightController,
                          decoration: const InputDecoration(labelText: 'Вес, г'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            final weight = int.tryParse(value ?? '');
                            if (weight == null || weight <= 0) {
                              return 'Укажите вес порции';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: imageController,
                          decoration: const InputDecoration(labelText: 'Изображение (URL)'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Укажите ссылку на изображение';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Показывать пользователям'),
                          value: isVisible,
                          onChanged: (value) => setState(() => isVisible = value),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Отмена'),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      final normalizedPrice = double.parse(
                        priceController.text.replaceAll(',', '.'),
                      );
                      final result = _DishEditorResult(
                        original: dish,
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        categoryId: selectedCategoryId,
                        price: normalizedPrice,
                        weight: int.parse(weightController.text),
                        imageUrl: imageController.text.trim(),
                        isVisible: isVisible,
                      );
                      Navigator.of(context).pop(result);
                    },
                    child: const Text('Сохранить'),
                  ),
                ],
              );
            },
          );
        },
      );
      if (result != null) {
        if (result.original != null) {
          final updated = result.original!.copyWith(
            name: result.name,
            description: result.description,
            categoryId: result.categoryId,
            price: result.price,
            weight: result.weight,
            imageUrl: result.imageUrl,
            isHidden: !result.isVisible,
          );
          await appState.updateDish(updated);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Блюдо "${updated.name}" обновлено')),
          );
        } else {
          final created = await appState.createDish(
            name: result.name,
            description: result.description,
            categoryId: result.categoryId,
            price: result.price,
            weight: result.weight,
            imageUrl: result.imageUrl,
            isHidden: !result.isVisible,
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Блюдо "${created.name}" создано')),
          );
        }
      }
    } finally {
      nameController.dispose();
      descriptionController.dispose();
      priceController.dispose();
      weightController.dispose();
      imageController.dispose();
    }
  }

  Future<void> _confirmDeleteDish(Dish dish) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить блюдо?'),
          content: Text('"${dish.name}" будет удалено без возможности восстановления.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
    if (shouldDelete == true) {
      await context.read<AppState>().deleteDish(dish.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Блюдо "${dish.name}" удалено')),
      );
    }
  }

  Future<void> _showUserOrders(AdminUser user) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Заказы пользователя ${user.displayName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: user.orders.isEmpty
                      ? const Center(child: Text('Заказы отсутствуют'))
                      : ListView.separated(
                          itemCount: user.orders.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final order = user.orders[index];
                            return ListTile(
                              title: Text('Заказ №${order.id} — ${_statusLabel(order.status)}'),
                              subtitle: Text('Создан: ${_formatOrderDate(order.createdAt)}'),
                              trailing: Text('${order.total.toStringAsFixed(0)} ₽'),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _categoryTitle(List<Category> categories, String categoryId) {
    final category = categories.firstWhere(
      (item) => item.id == categoryId,
      orElse: () => const Category(id: '', title: 'Без категории'),
    );
    return category.id.isEmpty ? 'Без категории' : category.title;
  }

  void _selectTime(BuildContext context, {required bool isOpening}) async {
    final initialTime = isOpening ? _openingTime : _closingTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingTime = picked;
        } else {
          _closingTime = picked;
        }
      });
    }
  }

  static List<TimeOfDay>? _parseWorkingHours(String workingHours) {
    final matches = RegExp(r'(\d{1,2}):(\d{2})').allMatches(workingHours).toList();
    if (matches.length >= 2) {
      final first = matches[0];
      final second = matches[1];
      final openHour = int.parse(first.group(1)!);
      final openMinute = int.parse(first.group(2)!);
      final closeHour = int.parse(second.group(1)!);
      final closeMinute = int.parse(second.group(2)!);
      return [
        TimeOfDay(hour: openHour, minute: openMinute),
        TimeOfDay(hour: closeHour, minute: closeMinute),
      ];
    }
    return null;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatOrderDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$day.$month.${date.year} $hours:$minutes';
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Ожидание';
      case OrderStatus.accepted:
        return 'Принят';
      case OrderStatus.cooking:
        return 'Готовится';
      case OrderStatus.delivering:
        return 'В доставке';
      case OrderStatus.completed:
        return 'Готов';
      case OrderStatus.cancelled:
        return 'Отменен';
    }
  }

  OrderStatus? _nextStatus(
    OrderStatus current,
    List<OrderStatus> activeStatuses,
  ) {
    final index = activeStatuses.indexOf(current);
    if (index == -1 || index >= activeStatuses.length - 1) {
      return null;
    }
    return activeStatuses[index + 1];
  }
}

class _DishEditorResult {
  const _DishEditorResult({
    required this.original,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.price,
    required this.weight,
    required this.imageUrl,
    required this.isVisible,
  });

  final Dish? original;
  final String name;
  final String description;
  final String categoryId;
  final double price;
  final int weight;
  final String imageUrl;
  final bool isVisible;
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
