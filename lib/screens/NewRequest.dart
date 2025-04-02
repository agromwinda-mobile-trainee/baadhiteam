import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RequestFormScreen extends StatefulWidget {
  final String token;
  const RequestFormScreen({Key? key, required this.token}) : super(key: key);

  @override
  _RequestFormScreenState createState() => _RequestFormScreenState();
}

class _RequestFormScreenState extends State<RequestFormScreen> {
  final TextEditingController _motifController = TextEditingController();
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
            SizedBox(height: 10),

            // Sélection du département
            DropdownButtonFormField<String>(
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
              onPressed: () {
                if (_motifController.text.isNotEmpty &&
                    selectedDepartment != null &&
                    selectedBudgetLine != null &&
                    selectedProject != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestLinesScreen(
                        token: widget.token,
                        motif: _motifController.text,
                        departmentId: selectedDepartment!,
                        budgetLineId: selectedBudgetLine!,
                        projectId: selectedProject!,
                      ),
                    ),
                  );
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



class RequestLinesScreen extends StatefulWidget {
  final String token;
  final String motif;
  final String departmentId;
  final String budgetLineId;
  final String projectId;

  const RequestLinesScreen({
    Key? key,
    required this.token,
    required this.motif,
    required this.departmentId,
    required this.budgetLineId,
    required this.projectId,
  }) : super(key: key);

  @override
  _RequestLinesScreenState createState() => _RequestLinesScreenState();
}

class _RequestLinesScreenState extends State<RequestLinesScreen> {
  List<Map<String, dynamic>> requestLines = [];

  void addRequestLine() {
    setState(() {
      requestLines.add({"designation": "", "total": 0, "unitPrice": 0});
    });
  }



  void submitRequisition() {
    double totalAmount = requestLines.fold(0, (sum, item) => sum + (item["total"] * item["unitPrice"]));

    Map<String, dynamic> requisitionData = {
      "motif": widget.motif,
      "departmentId": widget.departmentId,
      "budgetLineId": widget.budgetLineId,
      "projectId": widget.projectId,
      "lines": requestLines,
      "totalAmount": totalAmount,
    };

    print("Réquisition soumise: $requisitionData");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Réquisition soumise avec succès !")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lignes de Réquisition")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: requestLines.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: TextField(
                      decoration: InputDecoration(labelText: "Désignation"),
                      onChanged: (value) => requestLines[index]["designation"] = value,
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(labelText: "Quantité"),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => requestLines[index]["total"] = int.tryParse(value) ?? 0,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(labelText: "Prix Unitaire"),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => requestLines[index]["unitPrice"] = double.tryParse(value) ?? 0.0,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(onPressed: addRequestLine, child: Text("Ajouter une ligne")),
            SizedBox(height: 10),
            ElevatedButton(onPressed: submitRequisition, child: Text("Soumettre la réquisition")),
          ],
        ),
      ),
    );
  }
}