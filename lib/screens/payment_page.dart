import 'package:flutter/material.dart';
import 'dart:async';
import '../models/burger.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

/// Tela de Pagamento - CRUD completo com RESTful
class PaymentPage extends StatefulWidget {
  final List<Burger> cart;
  final double total;

  const PaymentPage({
    super.key,
    required this.cart,
    required this.total,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _apiService = ApiService();
  List<dynamic> _orders = [];
  bool _isProcessing = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _loadOrders(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    try {
      final data = await _apiService.getOrders();
      if (mounted) {
        setState(() => _orders = data);
      }
    } catch (e) {
      debugPrint('Erro ao carregar pedidos: $e');
    }
  }

  Future<void> _finalizePayment() async {
    if (widget.cart.isEmpty) {
      _showMessage('Carrinho vazio!', Colors.orange);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final orderData = {
        'title': 'Pedido #${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13)}',
        'status': 'ativo',
        'description':
            'Total: R\$ ${widget.total.toStringAsFixed(2)} - Itens: ${widget.cart.map((b) => b.name).join(", ")}',
        'items': widget.cart.map((b) => b.toJson()).toList(),
        'total': widget.total,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _apiService.createOrder(orderData);
      await LocalStorageService.saveLocalOrder(orderData);
      await LocalStorageService.clearCart();

      if (!mounted) return;
      _showMessage('Pedido realizado com sucesso!', Colors.green);
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Erro: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _updateOrder(dynamic id, String newStatus) async {
    try {
      final order = _orders.firstWhere((o) => o['id'] == id);
      final updatedData = {
        'title': order['title'],
        'status': newStatus,
        'description': order['description'],
      };

      await _apiService.updateOrder(id, updatedData);
      _showMessage('Pedido atualizado!', Colors.blue);
      _loadOrders();
    } catch (e) {
      _showMessage('Erro ao atualizar: $e', Colors.red);
    }
  }

  Future<void> _deleteOrder(dynamic id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('EXCLUIR'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.deleteOrder(id);
      _showMessage('Pedido excluído!', Colors.green);
      _loadOrders();
    } catch (e) {
      _showMessage('Erro ao excluir: $e', Colors.red);
    }
  }

  void _showMessage(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Sucesso!'),
          ],
        ),
        content: const Text('Seu pedido foi enviado para a cozinha!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> order) {
    String selectedStatus = order['status'] ?? 'ativo';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar Pedido'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Título: ${order['title']}'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedStatus,  // ✅ CORRIGIDO: value -> initialValue
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'ativo', child: Text('Ativo')),
                  DropdownMenuItem(value: 'preparando', child: Text('Preparando')),
                  DropdownMenuItem(value: 'entregue', child: Text('Entregue')),
                  DropdownMenuItem(value: 'cancelado', child: Text('Cancelado')),
                ],
                onChanged: (value) {
                  setDialogState(() {
                    selectedStatus = value ?? 'ativo';
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateOrder(order['id'], selectedStatus);
                Navigator.pop(context);
              },
              child: const Text('SALVAR'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildCurrentOrderCard(),
          const Divider(height: 1),
          Expanded(
            child: _orders.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum pedido no histórico',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return _buildOrderCard(order);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentOrderCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RESUMO DO PEDIDO ATUAL',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.cart.map((burger) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '• ${burger.name}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'R\$ ${burger.price.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )),
            const Divider(color: Colors.grey),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL:',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'R\$ ${widget.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _finalizePayment,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(
                  _isProcessing ? 'PROCESSANDO...' : 'CONFIRMAR PAGAMENTO',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] ?? 'inativo';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: const Icon(Icons.receipt, color: Colors.white, size: 20),
        ),
        title: Text(
          order['title'] ?? 'Pedido sem título',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          order['description'] ?? 'Sem descrição',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                status.toUpperCase(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              backgroundColor: statusColor,
              padding: EdgeInsets.zero,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditDialog(order);
                } else if (value == 'delete') {
                  _deleteOrder(order['id']);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text('Editar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Excluir'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'ativo':
        return Colors.green;
      case 'preparando':
        return Colors.orange;
      case 'entregue':
        return Colors.blue;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
