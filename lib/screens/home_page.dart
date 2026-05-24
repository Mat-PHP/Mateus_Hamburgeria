import 'package:flutter/material.dart';
import '../models/burger.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import 'payment_page.dart';
import 'login_page.dart';
import 'orders_page.dart';

/// Tela Principal - Cardápio de Hambúrgueres
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _apiService = ApiService();
  List<Burger> _burgers = [];
  List<Burger> _cart = [];
  bool _isLoading = true;
  String? _error;
  double get _total => _cart.fold(0, (sum, b) => sum + b.price);

  @override
  void initState() {
    super.initState();
    _loadBurgers();
    _loadCartFromLocal();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadBurgers() async {
    try {
      final data = await _apiService.getBurgers();
      setState(() {
        _burgers = data.map((json) => Burger.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _loadCartFromLocal() {
    final saved = LocalStorageService.loadCart();
    setState(() {
      _cart = saved.map((json) => Burger.fromJson(json)).toList();
    });
  }

  Future<void> _saveCartToLocal() async {
    final data = _cart.map((b) => b.toJson()).toList();
    await LocalStorageService.saveCart(data);
  }

  void _addToCart(Burger burger) {
    setState(() {
      _cart.add(burger);
    });
    _saveCartToLocal();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${burger.name} adicionado!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'VER CARRINHO',
          textColor: Colors.white,
          onPressed: _goToPayment,
        ),
      ),
    );
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
    });
    LocalStorageService.clearCart();
  }

  void _goToPayment() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Carrinho vazio!')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentPage(
          cart: _cart,
          total: _total,
        ),
      ),
    ).then((_) => _loadCartFromLocal());
  }

  void _logout() async {
    await LocalStorageService.clearUser();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mateus Hamburgueria'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Meus Pedidos',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrdersPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _error != null
              ? _buildErrorWidget()
              : _buildBody(),
      floatingActionButton: _cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _goToPayment,
              backgroundColor: Colors.green,
              icon: const Icon(Icons.shopping_cart),
              label: Text('${_cart.length} | R\$ ${_total.toStringAsFixed(2)}'),
            )
          : null,
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar cardápio',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadBurgers,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade700, Colors.orange.shade400],
            ),
          ),
          child: const Column(
            children: [
              Text(
                'PROMOÇÃO DO DIA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'X-Tudo por apenas R\$ 29,90!',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        if (_cart.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.green.shade50,
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_cart.length} item(s) no carrinho',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _clearCart,
                  child: const Text('LIMPAR'),
                ),
              ],
            ),
          ),
        Expanded(
          child: _burgers.isEmpty
              ? const Center(child: Text('Nenhum hambúrguer disponível'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _burgers.length,
                  itemBuilder: (context, index) {
                    final burger = _burgers[index];
                    return _buildBurgerCard(burger);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBurgerCard(Burger burger) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: const Icon(
              Icons.fastfood,
              size: 80,
              color: Colors.orange,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        burger.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        burger.category,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.orange.shade100,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  burger.description,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'R\$ ${burger.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _addToCart(burger),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('ADICIONAR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
