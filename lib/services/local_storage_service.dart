import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço de Persistência Local
/// Armazenamento interno do dispositivo (cache)
class LocalStorageService {
  static const String _cartKey = 'cart_items';
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _ordersKey = 'local_orders';

  static late SharedPreferences _prefs;

  /// Inicializa o SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== CARRINHO ====================

  /// Salva carrinho localmente
  static Future<bool> saveCart(List<Map<String, dynamic>> items) async {
    final jsonString = json.encode(items);
    return await _prefs.setString(_cartKey, jsonString);
  }

  /// Carrega carrinho salvo
  static List<Map<String, dynamic>> loadCart() {
    final jsonString = _prefs.getString(_cartKey);
    if (jsonString == null) return [];
    return List<Map<String, dynamic>>.from(json.decode(jsonString));
  }

  /// Limpa carrinho
  static Future<bool> clearCart() async {
    return await _prefs.remove(_cartKey);
  }

  // ==================== USUÁRIO ====================

  /// Salva dados do usuário logado
  static Future<bool> saveUser(Map<String, dynamic> user) async {
    final jsonString = json.encode(user);
    return await _prefs.setString(_userKey, jsonString);
  }

  /// Carrega dados do usuário
  static Map<String, dynamic>? loadUser() {
    final jsonString = _prefs.getString(_userKey);
    if (jsonString == null) return null;
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  /// Remove dados do usuário (logout)
  static Future<bool> clearUser() async {
    return await _prefs.remove(_userKey);
  }

  // ==================== TOKEN ====================

  static Future<bool> saveToken(String token) async {
    return await _prefs.setString(_tokenKey, token);
  }

  static String? loadToken() {
    return _prefs.getString(_tokenKey);
  }

  // ==================== PEDIDOS LOCAIS ====================

  static Future<bool> saveLocalOrder(Map<String, dynamic> order) async {
    final orders = loadLocalOrders();
    orders.add(order);
    return await _prefs.setString(_ordersKey, json.encode(orders));
  }

  static List<Map<String, dynamic>> loadLocalOrders() {
    final jsonString = _prefs.getString(_ordersKey);
    if (jsonString == null) return [];
    return List<Map<String, dynamic>>.from(json.decode(jsonString));
  }

  /// Limpa todo o armazenamento
  static Future<bool> clearAll() async {
    return await _prefs.clear();
  }
}
