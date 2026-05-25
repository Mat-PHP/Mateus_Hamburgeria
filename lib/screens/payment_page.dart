import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

const _pixCode = '00020126360014BR.GOV.BCB.PIX0114+5511999999999520400005303986'
    '540510.005802BR5913HAMBURGUERIA6009SAO PAULO62070503***6304ABCD';

class PaymentPage extends StatefulWidget {
  // CONFIGURAÇÃO DOS PARÂMETROS OBRIGATÓRIOS
  final int id;
  final String name;
  final double price;

  const PaymentPage({
    super.key,
    required this.id,
    required this.name,
    required this.price,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int quantidade = 1;
  String? _metodoPagamento;
  bool _enviando = false;
  final ApiService _apiService = ApiService();

  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _trocoController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _trocoController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calcula o preço total multiplicando o preço unitário que veio por parâmetro pela quantidade
    final double precoTotal = widget.price * quantidade;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Itens Selecionados',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'R\$ ${widget.price.toStringAsFixed(2)} cada',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () {
                              if (quantidade > 1) {
                                setState(() => quantidade--);
                              }
                            },
                          ),
                          Text(
                            '$quantidade',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline,
                                color: Colors.green),
                            onPressed: () {
                              setState(() => quantidade++);
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Card de Forma de Pagamento
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Forma de Pagamento',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      RadioGroup<String>(
                        groupValue: _metodoPagamento,
                        onChanged: (value) =>
                            setState(() => _metodoPagamento = value),
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: const Text('Pix'),
                              value: 'Pix',
                              activeColor: Colors.amber,
                              secondary: const Icon(Icons.pix),
                            ),
                            RadioListTile<String>(
                              title: const Text('Cartão de Crédito'),
                              value: 'Crédito',
                              activeColor: Colors.amber,
                              secondary: const Icon(Icons.credit_card),
                            ),
                            RadioListTile<String>(
                              title: const Text('Cartão de Débito'),
                              value: 'Débito',
                              activeColor: Colors.amber,
                              secondary: const Icon(Icons.credit_score),
                            ),
                            RadioListTile<String>(
                              title: const Text('Dinheiro'),
                              value: 'Dinheiro',
                              activeColor: Colors.amber,
                              secondary: const Icon(Icons.attach_money),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Card condicional com detalhes do método selecionado
              if (_metodoPagamento != null) ...[
                const SizedBox(height: 16),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildPaymentContent(context),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total do Pedido:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'R\$ ${precoTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _enviando
                      ? null
                      : () async {
                          if (_metodoPagamento == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.red,
                                content:
                                    Text('Selecione uma forma de pagamento'),
                              ),
                            );
                            return;
                          }
                          setState(() => _enviando = true);
                          try {
                            final orderData = {
                              'title': widget.name,
                              'description':
                                  'Pedido de ${widget.name} x$quantidade via $_metodoPagamento',
                              'status': 'ativo',
                              'burgerId': widget.id,
                              'quantity': quantidade,
                              'paymentMethod': _metodoPagamento,
                              'total': precoTotal,
                              'createdAt': DateTime.now().toIso8601String(),
                            };
                            await _apiService.createOrder(orderData);
                            await LocalStorageService.saveLocalOrder(orderData);
                            if (!context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Pedido confirmado'),
                                content: Text(
                                  'Item: ${widget.name}\n'
                                  'Quantidade: $quantidade\n'
                                  'Forma de pagamento: $_metodoPagamento\n'
                                  'Total: R\$ ${precoTotal.toStringAsFixed(2)}',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Pedido enviado com sucesso!'),
                                        ),
                                      );
                                      Navigator.pop(context);
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.red,
                                content: Text('Erro ao enviar pedido: $e'),
                              ),
                            );
                          } finally {
                            if (mounted) setState(() => _enviando = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _enviando
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Finalizar Compra',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentContent(BuildContext context) {
    switch (_metodoPagamento) {
      case 'Pix':
        return _buildPixContent(context);
      case 'Crédito':
      case 'Débito':
        return _buildCardContent();
      case 'Dinheiro':
        return _buildCashContent();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPixContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Pague com Pix',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        QrImageView(
          data: _pixCode,
          size: 200,
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const SelectableText(
            _pixCode,
            style: TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: _pixCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Código copiado!')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copiar código'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dados do Cartão',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _cardNumberController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Número do cartão',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cardNameController,
          decoration: const InputDecoration(
            labelText: 'Nome impresso no cartão',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _cardExpiryController,
                decoration: const InputDecoration(
                  labelText: 'Validade (MM/AA)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _cardCvvController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Pagamento processado na entrega',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildCashContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pagamento em Dinheiro',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _trocoController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Precisa de troco para quanto? (opcional)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Pague na entrega ao motoboy',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }
}
