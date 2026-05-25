import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'payment_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _futureBurgers;

  @override
  void initState() {
    super.initState();
    _futureBurgers = _apiService.getBurgers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mateus Hamburgueria'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureBurgers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum hambúrguer encontrado.'));
          }

          final lista = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: lista.length,
            itemBuilder: (context, index) {
              final item = Map<String, dynamic>.from(lista[index]);

              final String nome = (item['name'] ?? item['nome'] ?? 'Hambúrguer').toString();
              final String descricao = (item['description'] ?? item['descricao'] ?? '').toString();
              final String imagem = (item['imageUrl'] ?? item['imagemUrl'] ?? '').toString();
              
              final int id = item['id'] is int ? item['id'] : int.tryParse(item['id'].toString()) ?? 0;
              final double preco = item['price'] is num ? (item['price'] as num).toDouble() : double.tryParse(item['price'].toString()) ?? 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12.0),
                  // CORREÇÃO AQUI: Usa a variável 'imagem' para carregar a foto real da API
                  leading: imagem.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imagem,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                          ),
                        )
                      : const Icon(Icons.fastfood, size: 50, color: Colors.grey),
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(descricao),
                      const SizedBox(height: 8),
                      Text('R\$ ${preco.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentPage(id: id, name: nome, price: preco),
                        ),
                      );
                    },
                    child: const Text('Pedir'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
