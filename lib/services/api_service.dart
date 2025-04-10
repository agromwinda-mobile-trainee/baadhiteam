
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
        String name = data['firstname'];
        String lastname= data['lastname'];
        String email = data['email'];
        String phoneNumber = data ['phoneNumber'];
        List<dynamic> roles = data['roles'];


        // Stocker dans SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', token);
        await prefs.setString('firstname', name);
        await prefs.setString('lastname', lastname);
        await prefs.setString('email', email);
        await prefs.setString('phoneNumber', phoneNumber);
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


  //nouvelle requisition

  Future<Map<String, dynamic>?> createRequisition({
    required String currency,
    required String motif,
    required String departmentIri,
    required String projectIri,
  }) async {
    try {
      // Récupérer le token depuis SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("jwt");

      if (token == null) {
        print("Token introuvable !");
        return null;
      }

      final url = Uri.parse("$baseUrl/requisitions");
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "currency": currency,
          "motif": motif,
          "department": departmentIri,
          "project": projectIri,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body); // Retourner la réponse JSON
      } else {
        print("Erreur: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Erreur lors de la requête : $e");
      return null;
    }
  }


  //ajouter une ligne d'une requisition

  Future<List<Map<String, dynamic>>> fetchRequisitionLines({
    required String token,
    required  int requisitionId,
  }) async {
    final url = Uri.parse(
        'https://baadhiteammm.com/api/labels=$requisitionId');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      print('❌ Erreur: ${response.statusCode} - ${response.body}');
      return [];
    }
  }

  //soumettre une requisition

  Future<bool> submitRequisition(int id, String token) async {
    final url = Uri.parse('https://lbaadhiteam.com/api/requisitions/$id/opt/submit');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      print('Soumission réussie');
      return true;
    } else {
      print('Erreur lors de la soumission: ${response.body}');
      return false;
    }
  }


  //director

  Future<List<Map<String, dynamic>>> fetchRequisitionsToValidate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("jwt");

    if (token == null) {
      print("Token introuvable !");
    }

    final response = await http.get(
      Uri.parse('$baseUrl/requisitions?state=pending'),
      headers: {
        'Authorization': 'Bearer $token',
        "Accept": "application/json",
        "Content-Type":"application/json"
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print(response.statusCode);
      throw Exception('Erreur lors du chargement des réquisitions à valider');
    }
  }

  //sign
  Future<Map<String, dynamic>> fetchUserProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("jwt");

    if (token == null) {
      print("Token introuvable !");
    }
    final response = await http.get(
      Uri.parse('https://baadhiteam.com/api/user/other/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode==201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur de chargement du profil');
    }
  }

  Future<http.Response> validateRequisition(int id, String signatory) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("jwt");

    if (token == null) {
      print("Token introuvable !");
    }

    return http.post(
      Uri.parse('https://baadhiteam.com/api/requisitions/$id/opt/sign?signatory=$signatory'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({}),
    );
  }

}



