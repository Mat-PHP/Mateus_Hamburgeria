import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final ApiService _apiService = ApiService();
  String _formaPagamentoSelecionada = 'Cartão de Crédito';
  
  final TextEditingController _numeroCartaoController = TextEditingController();
  final TextEditingController _validadeController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _trocoController = TextEditingController();

  final List<String> _formasPagamento = ['Cartão de Crédito', 'Cartão de Débito', 'Pix', 'Dinheiro'];

  @override
  void dispose() {
    _numeroCartaoController.dispose();
    _validadeController.dispose();
    _cvvController.dispose();
    _trocoController.dispose();
    super.dispose();
  }

  // Função que envia o JSON para o db.json
  Future<void> _finalizarPedido() async {
    final Map<String, dynamic> dadosPedido = {
      "forma_pagamento": _formaPagamentoSelecionada,
      "data": DateTime.now().toIso8601String(),
      "status": "pendente",
      "detalhes": {
        "cartao_numero": _numeroCartaoController.text.isNotEmpty ? _numeroCartaoController.text : null,
        "troco_para": _trocoController.text.isNotEmpty ? _trocoController.text : null,
      }
    };

    try {
      await _apiService.createOrder(dadosPedido);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pedido enviado ao banco de dados!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar no JSON: $e')));
    }
  }

  Widget _buildCamposPagamento() {
    if (_formaPagamentoSelecionada.contains('Cartão')) {
      return Column(
        children: [
          TextField(controller: _numeroCartaoController, decoration: const InputDecoration(labelText: 'Número do Cartão', border: OutlineInputBorder()), keyboardType: TextInputType.number),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TextField(controller: _validadeController, decoration: const InputDecoration(labelText: 'Validade', border: OutlineInputBorder()))),
            const SizedBox(width: 10),
            Expanded(child: TextField(controller: _cvvController, decoration: const InputDecoration(labelText: 'CVV', border: OutlineInputBorder()), keyboardType: TextInputType.number)),
          ]),
        ],
      );
    } else if (_formaPagamentoSelecionada == 'Pix') {
      return const Column(children: [Icon(Icons.qr_code_2, size: 100), Text('Aguardando pagamento via Pix...')]);
    } else if (_formaPagamentoSelecionada == 'Dinheiro') {
      return TextField(controller: _trocoController, decoration: const InputDecoration(labelText: 'Troco para quanto?', border: OutlineInputBorder()), keyboardType: TextInputType.number);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Pagamento'), backgroundColor: Colors.orange),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey(_formaPagamentoSelecionada),
              initialValue: _formaPagamentoSelecionada,
              items: _formasPagamento.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
              onChanged: (val) => setState(() => _formaPagamentoSelecionada = val!),
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Forma de Pagamento'),
            ),
            const SizedBox(height: 20),
            _buildCamposPagamento(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _finalizarPedido,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.all(16)),
              child: const Text('Confirmar Pedido', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}