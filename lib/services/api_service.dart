import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
// CORREÇÃO DO ERRO AQUI: Este import conecta o serviço ao arquivo que você já criou
import '../models/burger.dart';

/// Serviço de API - Integração com RESTful Web Service
/// Implementa GET, POST, PUT, DELETE utilizando Orientação a Objetos
class ApiService {
  static const String baseUrl = 'http://192.168.0.195:30';

  final http.Client _client = http.Client();

  // ==================== BURGERS ====================

  /// GET - Lista todos os hambúrgueres (C17 - 6.1.1 GET)
  Future<List<Burger>> getBurgers() async {
    final response = await _client.get(Uri.parse('$baseUrl/burgers'));
    if (response.statusCode == 200) {
      final List<dynamic> decodedList = json.decode(response.body);
      // Converte a lista de mapas do json-server em objetos do tipo Burger
      return decodedList.map((item) => Burger.fromJson(item)).toList();
    }
    throw Exception('Falha ao carregar hambúrgueres: ${response.statusCode}');
  }

  /// GET by ID - Busca hambúrguer específico
  Future<Burger> getBurgerById(int id) async {
    final response = await _client.get(Uri.parse('$baseUrl/burgers/$id'));
    if (response.statusCode == 200) {
      return Burger.fromJson(json.decode(response.body));
    }
    throw Exception('Hambúrguer não encontrado: ${response.statusCode}');
  }

  /// POST - Cria novo hambúrguer (C17 - 6.1.2 POST)
  Future<Burger> createBurger(Burger burger) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/burgers'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(burger.toJson()),
    );
    if (response.statusCode == 201) {
      return Burger.fromJson(json.decode(response.body));
    }
    throw Exception('Falha ao criar hambúrguer: ${response.statusCode}');
  }

  /// PUT - Atualiza hambúrguer (C17 - 6.1.3 PUT)
  Future<Burger> updateBurger(int id, Burger burger) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/burgers/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(burger.toJson()),
    );
    if (response.statusCode == 200) {
      return Burger.fromJson(json.decode(response.body));
    }
    throw Exception('Falha ao atualizar hambúrguer: ${response.statusCode}');
  }

  /// DELETE - Remove hambúrguer (C17 - 6.1.4 DELETE)
  Future<void> deleteBurger(int id) async {
    final response = await _client.delete(Uri.parse('$baseUrl/burgers/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao deletar hambúrguer: ${response.statusCode}');
    }
  }

  // ==================== USUÁRIOS ====================

  /// GET - Lista usuários
  Future<List<dynamic>> getUsers() async {
    final response = await _client.get(Uri.parse('$baseUrl/usuarios'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Falha ao carregar usuários: ${response.statusCode}');
  }

  /// POST - Login com email e senha
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/usuarios?email=$email'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> users = json.decode(response.body);
      if (users.isEmpty) throw Exception('Usuário não encontrado');

      final user = Map<String, dynamic>.from(users.first);

      if (user['senha'] != password) {
        throw Exception('Senha incorreta');
      }
      return user;
    }
    throw Exception('Erro ao conectar com servidor');
  }

  // ==================== PEDIDOS (telalocal) ====================

  /// Helper de retry com laço 'while' explícito
  Future<http.Response> _getWithRetry(Uri url, {int maxAttempts = 3}) async {
    int attempt = 0;
    while (attempt < maxAttempts) {
      try {
        final r = await _client.get(url);
        if (r.statusCode < 500) return r;
      } catch (_) {}
      attempt++;
      await Future.delayed(Duration(milliseconds: 300 * attempt));
    }
    throw Exception('Falha após $maxAttempts tentativas');
  }

  /// GET - Lista pedidos (usa retry com while)
  Future<List<dynamic>> getOrders() async {
    final response = await _getWithRetry(Uri.parse('$baseUrl/telalocal'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Falha ao carregar pedidos: ${response.statusCode}');
  }

  /// POST - Cria novo pedido
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/telalocal'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(json.decode(response.body));
    }
    throw Exception('Falha ao criar pedido: ${response.statusCode}');
  }

  /// PUT - Atualiza pedido
  Future<Map<String, dynamic>> updateOrder(
      int id, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/telalocal/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    }
    throw Exception('Falha ao atualizar pedido: ${response.statusCode}');
  }

  /// DELETE - Remove pedido
  Future<void> deleteOrder(int id) async {
    final response = await _client.delete(Uri.parse('$baseUrl/telalocal/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao deletar pedido: ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}
