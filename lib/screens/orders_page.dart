import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

/// Tela de Histórico de Pedidos - Visualização de dados persistidos
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final _apiService = ApiService();
  List<dynamic> _serverOrders = [];
  List<Map<String, dynamic>> _localOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllOrders();
  }

  Future<void> _loadAllOrders() async {
    setState(() => _isLoading = true);

    // Carrega do servidor (GET)
    try {
      _serverOrders = await _apiService.getOrders();
    } catch (e) {
      debugPrint('Erro servidor: $e');
    }

    // Carrega do armazenamento local
    _localOrders = LocalStorageService.loadLocalOrders();

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _deleteOrder(dynamic order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar pedido?'),
        content: const Text('Tem certeza que deseja cancelar este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Não'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sim', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final id = order['id'];
      await _apiService.deleteOrder(id is int ? id : int.parse(id.toString()));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido cancelado')),
      );
      _loadAllOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Erro ao cancelar pedido: $e'),
        ),
      );
    }
  }

  Future<void> _updateOrderPago(dynamic order) async {
    try {
      final id = order['id'];
      final updateData = Map<String, dynamic>.from(order as Map);
      updateData['status'] = 'pago';
      await _apiService.updateOrder(
          id is int ? id : int.parse(id.toString()), updateData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido marcado como pago')),
      );
      _loadAllOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Erro ao atualizar pedido: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meus Pedidos'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.cloud), text: 'Servidor'),
              Tab(icon: Icon(Icons.phone_android), text: 'Local'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.orange))
            : TabBarView(
                children: [
                  _buildServerOrdersTab(),
                  _buildLocalOrdersTab(),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _loadAllOrders,
          backgroundColor: Colors.orange,
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Widget _buildServerOrdersTab() {
    if (_serverOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhum pedido no servidor', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Laço 'for' explícito para calcular o total geral dos pedidos
    double totalGeral = 0;
    for (var order in _serverOrders) {
      totalGeral += (order['total'] as num? ?? 0).toDouble();
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.orange[50],
          child: Text(
            'Total geral: R\$ ${totalGeral.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _serverOrders.length,
            itemBuilder: (context, index) {
              final order = _serverOrders[index];
              return _buildOrderTile(order, isLocal: false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocalOrdersTab() {
    if (_localOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storage, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhum pedido salvo localmente', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _localOrders.length,
      itemBuilder: (context, index) {
        final order = _localOrders[index];
        return _buildOrderTile(order, isLocal: true);
      },
    );
  }

  Widget _buildOrderTile(dynamic order, {required bool isLocal}) {
    final status = order['status'] ?? 'inativo';
    final title = order['title'] ?? 'Pedido sem título';
    final description = order['description'] ?? 'Sem descrição';
    final createdAt = order['createdAt'] ?? DateTime.now().toIso8601String();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          isLocal ? Icons.phone_android : Icons.cloud_done,
          color: isLocal ? Colors.green : Colors.blue,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Status: ${status.toUpperCase()}',
          style: TextStyle(
            color: _getStatusColor(status),
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Chip(
          label: Text(
            isLocal ? 'LOCAL' : 'NUVEM',
            style: const TextStyle(fontSize: 10, color: Colors.white),
          ),
          backgroundColor: isLocal ? Colors.green : Colors.blue,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Descrição: $description'),
                const SizedBox(height: 8),
                Text('Data: ${_formatDate(createdAt)}'),
                if (order['total'] != null)
                  Text(
                    'Total: R\$ ${(order['total'] as num).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 18,
                    ),
                  ),
                if (!isLocal) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.check_circle,
                          color: status.toLowerCase() == 'pago'
                              ? Colors.grey
                              : Colors.green,
                        ),
                        tooltip: 'Marcar como pago',
                        onPressed: status.toLowerCase() == 'pago'
                            ? null
                            : () => _updateOrderPago(order),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Cancelar pedido',
                        onPressed: () => _deleteOrder(order),
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

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate;
    }
  }
}
