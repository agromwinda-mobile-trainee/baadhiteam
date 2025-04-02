
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "https://baadhiteam.com/api";


  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login_check_jwt');

    try {
      final response = await http.post(
        url,
        headers: {"Accept": "application/json",
                   "Content-Type":"application/json"
        },
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
        print(username);
        print(password);
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

//liste des departements
  //String token = await login.token('USD', 'First test Api yum');
  Future<List<Map<String, dynamic>>> fetchDepartments(String token) async {
    final String? token = await getToken();
    if (token == null) return [];
    final response = await http.get(
      Uri.parse('$baseUrl/v2/departments/my'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.cast<Map<String, dynamic>>();
    } else {
      print(response.statusCode);
      throw Exception('Erreur lors de la récupération des départements');
    }
  }



//ligne budgetaire

 Future<List<Map<String, dynamic>>> fetchBudgetLines(String token) async {
  final response = await http.get(
  Uri.parse('$baseUrl/v2/budget_lines'),
  headers: {
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',
  },
  );

  if (response.statusCode == 200) {
  List<dynamic> jsonResponse = json.decode(response.body);
  return jsonResponse.cast<Map<String, dynamic>>();
  } else {
  throw Exception('Erreur lors de la récupération des lignes budgétaires');
  }
  }

  //liste projet




  Future<List<Map<String, dynamic>>> fetchProjects(String token) async {
  final response = await http.get(
  Uri.parse("$baseUrl/v2/projects/my"),
  headers: {
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',
  },
  );

  if (response.statusCode == 200) {
  List<dynamic> data = jsonDecode(response.body);
  return data.map((project) => {
  "id": project["id"],
  "name": project["name"],
  }).toList();
  } else {
  throw Exception("Échec du chargement des projets");
  }
  }

}
