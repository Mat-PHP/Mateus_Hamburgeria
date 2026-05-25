import 'dart:convert'; // Necessário para converter JSON (decodificar/codificar)
import 'dart:async';   // Necessário para lidar com operações assíncronas (Future)
import 'package:http/http.dart' as http; // Biblioteca para requisições HTTP
import '../models/burger.dart'; // Import do seu modelo de dados

/// Serviço de API - Gerencia a comunicação do App com o servidor (json-server)
class ApiService {
  // A URL base deve apontar para o IP da sua máquina e a PORTA correta.
  // IMPORTANTE: Altere de 300 para 3000 para coincidir com o servidor.
  static const String baseUrl = 'http://10.109.72.26:300';

  // Cliente HTTP reutilizável para manter a conexão ativa
  final http.Client _client = http.Client();

  // ==================== BURGERS (Operações CRUD) ====================

  /// GET: Busca todos os hambúrgueres cadastrados no db.json
  Future<List<Burger>> getBurgers() async {
    final response = await _client.get(Uri.parse('$baseUrl/burgers'));
    if (response.statusCode == 200) {
      final List<dynamic> decodedList = json.decode(response.body);
      // Transforma a lista de mapas em objetos do tipo Burger
      return decodedList.map((item) => Burger.fromJson(item)).toList();
    }
    throw Exception('Falha ao carregar hambúrgueres: ${response.statusCode}');
  }

  /// GET by ID: Busca apenas um hambúrguer pelo seu ID
  Future<Burger> getBurgerById(int id) async {
    final response = await _client.get(Uri.parse('$baseUrl/burgers/$id'));
    if (response.statusCode == 200) {
      return Burger.fromJson(json.decode(response.body));
    }
    throw Exception('Hambúrguer não encontrado: ${response.statusCode}');
  }

  /// POST: Envia um novo hambúrguer para ser salvo no db.json
  Future<Burger> createBurger(Burger burger) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/burgers'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(burger.toJson()),
    );
    if (response.statusCode == 201) { // 201 significa "Criado com sucesso"
      return Burger.fromJson(json.decode(response.body));
    }
    throw Exception('Falha ao criar hambúrguer: ${response.statusCode}');
  }

  /// PUT: Atualiza um hambúrguer existente via ID
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

  /// DELETE: Remove um hambúrguer do db.json
  Future<void> deleteBurger(int id) async {
    final response = await _client.delete(Uri.parse('$baseUrl/burgers/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao deletar hambúrguer: ${response.statusCode}');
    }
  }

  // ==================== USUÁRIOS ====================

  /// GET: Lista todos os usuários
  Future<List<dynamic>> getUsers() async {
    final response = await _client.get(Uri.parse('$baseUrl/usuarios'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Falha ao carregar usuários: ${response.statusCode}');
  }

  /// Lógica de Autenticação: Busca usuário por e-mail e verifica a senha
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
      return user; // Retorna os dados do usuário logado
    }
    throw Exception('Erro ao conectar com servidor');
  }

  // ==================== PEDIDOS ====================

  /// Função auxiliar com tentativa de reconexão (Retry) em caso de falha de rede
  Future<http.Response> _getWithRetry(Uri url, {int maxAttempts = 3}) async {
    int attempt = 0;
    while (attempt < maxAttempts) {
      try {
        final r = await _client.get(url);
        if (r.statusCode < 500) return r; // Sucesso ou erro do cliente
      } catch (_) {}
      attempt++;
      await Future.delayed(Duration(milliseconds: 300 * attempt));
    }
    throw Exception('Falha após $maxAttempts tentativas');
  }

  /// GET: Busca a lista de pedidos salvos
  Future<List<dynamic>> getOrders() async {
    final response = await _getWithRetry(Uri.parse('$baseUrl/pedidos'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Falha ao carregar pedidos: ${response.statusCode}');
  }

  /// POST: Salva um novo pedido no servidor
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> data) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/pedidos'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return Map<String, dynamic>.from(json.decode(response.body));
    }
    throw Exception('Falha ao criar pedido: ${response.statusCode}');
  }

  /// PUT: Atualiza o status de um pedido existente
  Future<Map<String, dynamic>> updateOrder(int id, Map<String, dynamic> data) async {
    final response = await _client.put(
      Uri.parse('$baseUrl/pedidos/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(json.decode(response.body));
    }
    throw Exception('Falha ao atualizar pedido: ${response.statusCode}');
  }

  /// DELETE: Remove um pedido do db.json
  Future<void> deleteOrder(int id) async {
    final response = await _client.delete(Uri.parse('$baseUrl/pedidos/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Falha ao deletar pedido: ${response.statusCode}');
    }
  }

  /// Fecha o cliente HTTP para liberar recursos da memória
  void dispose() {
    _client.close();
  }
}