
import 'package:baadhi_team/screens/NewRequest.dart';
import 'package:baadhi_team/screens/requisition_lines.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class RequestScreen extends StatefulWidget {
  final bool isDirector;

  const RequestScreen({super.key, required this.isDirector});

  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  final ApiService apiService = ApiService();
  List<Map<String, dynamic>> requisitions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequisitions();
  }


  void _loadRequisitions() async {
    List<Map<String, dynamic>> data;
    if (widget.isDirector) {
      data = await apiService.fetchRequisitionsToValidate(); // route API spéciale directeur
    } else {
      data = await apiService.fetchRequisitions(); // route normale utilisateur
    }

    setState(() {
      requisitions = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Réquisitions")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: requisitions.length,
        itemBuilder: (context, index) {
          final req = requisitions[index];
          return Card(
            child: ListTile(
              title: Text("Motif : ${req['motif']}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Département : ${req['department']['name']}"),
                  Text("Montant : ${req['amount']} ${req['currency']}"),
                  Text("Par : ${req ['owner']['names']}")
                ],
              ),
              trailing: widget.isDirector
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {}, // Ajouter l'action d'approbation
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {}, // Ajouter l'action de rejet
                  ),
                ],
              )
                  : null,
              onTap: ()async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? userToken = prefs.getString("jwt");
                if (userToken != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequisitionLinesScreen(
                        requisitionId: req['id'],
                        token: userToken, isDirector: widget.isDirector,
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
      floatingActionButton: widget.isDirector
          ? null
          : FloatingActionButton(
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? userToken = prefs.getString("jwt"); // Récupération du token

            if (userToken != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RequestFormScreen(token: userToken),
                ),
              );
            } else {
              print("Token introuvable !");
            }
          },
        child: const Icon(Icons.add),
      ),
    );
  }
}