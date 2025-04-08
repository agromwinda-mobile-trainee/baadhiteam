

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DirectorRequisitionListScreen extends StatefulWidget {
  const DirectorRequisitionListScreen({super.key});

  @override
  State<DirectorRequisitionListScreen> createState() => _DirectorRequisitionListScreenState();
}

class _DirectorRequisitionListScreenState extends State<DirectorRequisitionListScreen> {
  final ApiService apiService = ApiService();
  bool isLoading = true;
  List<Map<String, dynamic>> requisitions = [];

  @override
  void initState() {
    super.initState();
    loadRequisitions();
  }

  void loadRequisitions() async {
    try {
      final data = await apiService.fetchRequisitionsToValidate();
      setState(() {
        requisitions = data;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur de chargement: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Réquisitions à valider")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requisitions.isEmpty
          ? const Center(child: Text("Aucune réquisition en attente de validation."))
          : ListView.builder(
        itemCount: requisitions.length,
        itemBuilder: (context, index) {
          final req = requisitions[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text("Motif : ${req['motif']}"),
              subtitle: Text("Montant : ${req['amount']}"),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // TODO: Aller vers la page de détails
                print("Voir détails de la réquisition ${req['id']}");
              },
            ),
          );
        },
      ),
    );
  }
}



