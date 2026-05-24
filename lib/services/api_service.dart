import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

/// Serviço de API - Integração com RESTful Web Service
/// Implementa GET, POST, PUT, DELETE
class ApiService {
  static const String baseUrl = 'http://10.109.72.17:30';

  final http.Client _client = http.Client();

  // ==================== BURGERS ====================

  /// GET - Lista todos os hambúrgueres
  Future<List<dynamic>> getBurgers() async {
    final response = await _client.get(Uri.parse('$baseUrl/burgers'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Falha ao carregar hambúrgueres: ${response.statusCode}');
  }

  /// GET by ID - Busca hambúrguer específico
  Future<Map<String, dynamic>> getBurgerById(int id) async {
    final response = await _client.get(Uri.parse('$baseUrl/burgers/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Hambúrguer não encontrado: ${response.statusCode}');
  }

  /// POST - Cria novo hambúrguer
  Future<Map<String, dynamic>> createBurger(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/burgers'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception('Falha ao criar hambúrguer: ${response.statusCode}');
  }

  /// PUT - Atualiza hambúrguer
  Future<Map<String, dynamic>> updateBurger(int id, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/burgers/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Falha ao atualizar hambúrguer: ${response.statusCode}');
  }

  /// DELETE - Remove hambúrguer
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

      final user = users.first as Map<String, dynamic>;
      if (user['senha'] != password) {
        throw Exception('Senha incorreta');
      }
      return user;
    }
    throw Exception('Erro ao conectar com servidor');
  }

  // ==================== PEDIDOS (telalocal) ====================

  /// GET - Lista pedidos
  Future<List<dynamic>> getOrders() async {
    final response = await _client.get(Uri.parse('$baseUrl/telalocal'));
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
      return json.decode(response.body);
    }
    throw Exception('Falha ao criar pedido: ${response.statusCode}');
  }

  /// PUT - Atualiza pedido
  Future<Map<String, dynamic>> updateOrder(int id, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/telalocal/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
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
