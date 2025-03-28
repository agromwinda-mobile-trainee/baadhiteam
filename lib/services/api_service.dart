
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "https://baadhiteam.com/api";

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login_check_jwt');

    try {
      final response = await http.post(
        url,
        headers: {"Accept": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Récupération du JWT et des infos utilisateur
        String token = data['jwt'];
        String name = data['name'];
        String email = data['email'];
        List<dynamic> roles = data['roles'];

        // Stocker dans SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', token);
        await prefs.setString('name', name);
        await prefs.setString('email', email);
        await prefs.setStringList('roles', roles.map((e) => e.toString()).toList());

        return true;
      } else {
        print("Échec de connexion: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erreur de connexion: $e");
      return false;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt');
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      "name": prefs.getString('name'),
      "email": prefs.getString('email'),
      "roles": prefs.getStringList('roles') ?? [],
    };
  }

  Future<List<Map<String, dynamic>>> fetchRequisitions() async {
    final String? token = await getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$baseUrl/requisitions'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print("Erreur lors de la récupération : ${response.body}");
      return [];
    }
  }
}