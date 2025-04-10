import 'dart:convert';

import 'package:baadhi_team/screens/requisition_lines.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class RequestFormScreen extends StatefulWidget {
  final String token;
  const RequestFormScreen({Key? key, required this.token}) : super(key: key);

  @override
  _RequestFormScreenState createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final TextEditingController _motifController = TextEditingController();
  String selectedCurrency = "USD";
  ApiService apiService = ApiService();

  List<Map<String, dynamic>> departments = [];
  List<Map<String, dynamic>> budgetLines = [];
  List<Map<String, dynamic>> projects = [];

  String? selectedDepartment;
  String? selectedBudgetLine;
  String? selectedProject;


  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void submitRequisition() async {
    if (selectedDepartment == null || selectedProject == null
    ) {
      print("Veuillez sélectionner un département et un projet !");
      return;
    }
    // Récupérer le token depuis SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("jwt");

    if (token == null) {
      print("Token introuvable !");
      return null;
    }

    final response = await http.post(
      Uri.parse('https://baadhiteam.com/api/requisitions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "currency": selectedCurrency,
        "motif": _motifController.text,
        "department": "/api/departments/$selectedDepartment",
        "project": "/api/projects/$selectedProject",
        "budgetLine":"api/budget_lines/$selectedBudgetLine"
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      debugPrint("Réquisition créée: ${response.body}");

      // Vérifie que l’ID existe avant la redirection
      if (responseData.containsKey("id")) {
        int requisitionId = responseData["id"];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RequisitionLinesScreen(
              token: token,
              requisitionId: requisitionId,
              isDirector: false,
            ),
          ),
        );
      } else {
        debugPrint("Erreur: ID de réquisition introuvable dans la réponse.");
      }
    } else {
      debugPrint("❌ Erreur: ${response.statusCode} - ${response.body}");
    }


  }

  void fetchData() async {
    try {
      List<Map<String, dynamic>> fetchedDepartments = await apiService.fetchDepartments(widget.token);
      List<Map<String, dynamic>> fetchedBudgetLines = await apiService.fetchBudgetLines(widget.token);
      List<Map<String, dynamic>> fetchedProjects = await apiService.fetchProjects(widget.token);

      setState(() {
        departments = fetchedDepartments;
        budgetLines = fetchedBudgetLines;
        projects = fetchedProjects;
      });
    } catch (e) {
      print('Erreur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nouvelle Réquisition")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _motifController,
              decoration: InputDecoration(labelText: "Motif de la réquisition"),
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedCurrency,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCurrency = newValue!;
                });
              },
              items: ["USD", "CDF"].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 10),
            // Sélection du département
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(labelText: "Département"),
              value: selectedDepartment,
              onChanged: (value) => setState(() => selectedDepartment = value),
              items: departments.map((dept) {
                return DropdownMenuItem<String>(
                  value: dept["id"].toString(),
                  child: Text(dept["name"]),
                );
              }).toList(),
            ),
            SizedBox(height: 10),

            // Sélection de la ligne budgétaire
            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: InputDecoration(labelText: "Ligne Budgétaire"),
              value: selectedBudgetLine,
              onChanged: (value) => setState(() => selectedBudgetLine = value),
              items: budgetLines.map((line) {
                return DropdownMenuItem<String>(
                  value: line["id"].toString(),
                  child: Text(line["wording"]),
                );
              }).toList(),
            ),
            SizedBox(height: 10),


            // Sélection du projet
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: "Projet"),
              value: selectedProject,
              onChanged: (value) => setState(() => selectedProject = value),
              items: projects.map((project) {
                return DropdownMenuItem<String>(
                  value: project["id"].toString(),
                  child: Text(project["name"]),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (_motifController.text.isNotEmpty &&
                    selectedDepartment != null
                   &&
                   selectedBudgetLine != null &&
                   selectedProject != null
                ) {
                  submitRequisition();
                  debugPrint("Token utilisé : $widget.token");

                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? storedToken = prefs.getString('jwt');
                  debugPrint("Token stocké: $storedToken");
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Veuillez remplir tous les champs")),
                  );
                }
              },
              child: Text("Suivant"),
            ),
          ],
        ),
      ),
    );
  }
}
