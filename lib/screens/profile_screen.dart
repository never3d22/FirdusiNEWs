import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/order.dart' show UserProfile;
import '../providers/app_state.dart';
import 'admin_dashboard_screen.dart';
import 'admin_login_screen.dart';
import 'password_login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _utensilsController;
  UserProfile? _lastProfileSnapshot;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppState>().profile;
    _nameController = TextEditingController(text: profile.fullName);
    _phoneController = TextEditingController(text: profile.phone);
    _addressController = TextEditingController(text: profile.defaultAddress);
    _utensilsController = TextEditingController(text: profile.utensilsCount.toString());
    _lastProfileSnapshot = profile;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _utensilsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppState>();
    await appState.updateProfile(
      appState.profile.copyWith(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        defaultAddress: _addressController.text.trim(),
        utensilsCount: int.tryParse(_utensilsController.text.trim()) ?? 0,
      ),
    );
    _lastProfileSnapshot = appState.profile;
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Данные сохранены')));
    }
  }

  void _syncProfile(UserProfile profile) {
    final snapshot = _lastProfileSnapshot;
    final hasChanges = snapshot == null ||
        snapshot.fullName != profile.fullName ||
        snapshot.phone != profile.phone ||
        snapshot.defaultAddress != profile.defaultAddress ||
        snapshot.utensilsCount != profile.utensilsCount;
    if (!hasChanges) return;
    if (_nameController.text != profile.fullName) {
      _nameController.text = profile.fullName;
    }
    if (_phoneController.text != profile.phone) {
      _phoneController.text = profile.phone;
    }
    if (_addressController.text != profile.defaultAddress) {
      _addressController.text = profile.defaultAddress;
    }
    final utensilsText = profile.utensilsCount.toString();
    if (_utensilsController.text != utensilsText) {
      _utensilsController.text = utensilsText;
    }
    _lastProfileSnapshot = profile;
  }

  Widget _buildRestaurantInfoCard(AppState appState) {
    final restaurantInfo = appState.restaurantInfo;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.storefront_outlined),
            title: Text(
              restaurantInfo.name.isNotEmpty
                  ? restaurantInfo.name
                  : 'Название не указано',
            ),
            subtitle: const Text('Название ресторана'),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.schedule_outlined),
            title: Text(
              restaurantInfo.workingHours.isNotEmpty
                  ? restaurantInfo.workingHours
                  : 'График не указан',
            ),
            subtitle: const Text('График работы'),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.phone_outlined),
            title: Text(
              restaurantInfo.phone.isNotEmpty
                  ? restaurantInfo.phone
                  : 'Телефон не указан',
            ),
            subtitle: const Text('Контактный телефон'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    _syncProfile(appState.profile);
    final isAuthenticated = appState.isAuthenticated;
    final isAdmin = appState.isAdminAuthenticated;
    final restaurantInfoCard = _buildRestaurantInfoCard(appState);
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDF5F5), Color(0xFFFFFCF8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              restaurantInfoCard,
              const SizedBox(height: 20),
              if (!isAuthenticated) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Войдите в аккаунт',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Сохраните контакты, адреса и оформляйте заказы быстрее. ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            PasswordLoginScreen.routeName,
                          ),
                          icon: const Icon(Icons.login),
                          label: const Text('Войти'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Личные данные',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Имя и фамилия'),
                          validator: (value) => value == null || value.isEmpty ? 'Заполните имя' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Телефон'),
                          keyboardType: TextInputType.phone,
                          validator: (value) => value == null || value.isEmpty ? 'Укажите телефон' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(labelText: 'Адрес по умолчанию'),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _utensilsController,
                          decoration: const InputDecoration(labelText: 'Приборы по умолчанию'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: _save,
                            child: const Text('Сохранить изменения'),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.receipt_long),
                        title: const Text('История заказов'),
                        subtitle: Text('Вы оформляли ${appState.orders.length} заказов'),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: const Text('Выйти из аккаунта'),
                        onTap: () async {
                          await context.read<AppState>().signOut();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Вы вышли из аккаунта')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Card(
                child: ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: const Text('Панель администратора'),
                  subtitle: Text(
                    isAdmin
                        ? 'Вход выполнен, можно управлять приложением'
                        : 'Управление меню, заказами и пользователями',
                  ),
                  trailing: isAdmin
                      ? IconButton(
                          tooltip: 'Выйти',
                          icon: const Icon(Icons.logout),
                          onPressed: () async {
                            await context.read<AppState>().signOutAdmin();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Вы вышли из админ-панели')),
                            );
                          },
                        )
                      : const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.pushNamed(
                    context,
                    isAdmin
                        ? AdminDashboardScreen.routeName
                        : AdminLoginScreen.routeName,
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
