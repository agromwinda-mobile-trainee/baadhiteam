

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import 'RequestScreen.dart';

class RequisitionLinesScreen extends StatefulWidget {
  final String token;
  final int requisitionId;
  final bool isDirector;


  const RequisitionLinesScreen({
    super.key,
    required this.token,
    required this.requisitionId, required this.isDirector,
  });

  @override
  State<RequisitionLinesScreen> createState() => _RequisitionLinesScreenState();
}

class _RequisitionLinesScreenState extends State<RequisitionLinesScreen> {
  Map<String, dynamic>? requisition;
  bool isLoading = true;
  Map<String, dynamic>? requisitionDetail;
 bool isDirector = false;


  @override
  void initState() {
    super.initState();
    fetchRequisition();
  }

  Future<void> fetchRequisition() async {
    final response = await http.get(
      Uri.parse('https://baadhiteam.com/api/requisitions/${widget.requisitionId}'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        requisitionDetail = json.decode(response.body);
        requisition = json.decode(response.body);
        isLoading = false;
      });
    } else {
      print("❌ Erreur: ${response.statusCode} - ${response.body}");
    }
  }

  Future<bool> submitRequisition(int id, String token) async {
    final url = Uri.parse('https://baadhiteam.com/api/requisitions/$id/opt/submit');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200 || response.statusCode==201) {
      return true;
    } else {
      print('Erreur: ${response.statusCode} - ${response.body}');
      return false;
    }
  }


  Future<void> addLabel(String description, int quantity, String unitCost) async {
    final response = await http.post(
      Uri.parse('https://baadhiteam.com/api/labels'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'description': description,
        'quantity': quantity,
        'unitCost': unitCost,
        'requisition': '/api/requisitions/${widget.requisitionId}',
      }),
    );

    if (response.statusCode == 201) {
      Navigator.of(context).pop(); // Fermer le dialogue
      await fetchRequisition();    // Refresh après ajout
    } else {
      print("Erreur d'ajout: ${response.statusCode} - ${response.body}");
    }
  }


  void openAddLabelDialog() {
    final descCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final unitCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Ajouter une ligne"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: "Quantité"), keyboardType: TextInputType.number),
            TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: "Prix unitaire"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              final desc = descCtrl.text;
              final qty = int.tryParse(qtyCtrl.text) ?? 0;
              final unit = unitCtrl.text;
              if (desc.isNotEmpty && qty > 0 && unit.isNotEmpty) {
                addLabel(desc, qty, unit);
              }
            },
            child: const Text("Ajouter"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    print("État de la réquisition : ${requisitionDetail!['state']}");

    //director

    // if (widget.isDirector && requisitionDetail != null && requisitionDetail!['state'] == 'pending')
    // {
    //   return ElevatedButton.icon(
    //     onPressed: () async {
    //       final id = requisitionDetail!['id'];
    //       final url = 'https://baadhiteam.com/api/requisitions/$id/opt/sign?signatory=mTime';
    //
    //       final response = await http.post(
    //         Uri.parse(url),
    //         headers: {
    //           'Authorization': 'Bearer ${widget.token}',
    //           'Content-Type': 'application/json',
    //         },
    //         body: jsonEncode({}), // L'API demande un body vide
    //       );
    //
    //       if (response.statusCode == 200) {
    //         // Recharge les détails
    //         await fetchRequisition();
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           const SnackBar(content: Text("Réquisition validée avec succès")),
    //         );
    //         setState(() {});
    //       } else {
    //         print('Erreur: ${response.statusCode} - ${response.body}');
    //         ScaffoldMessenger.of(context).showSnackBar(
    //           const SnackBar(content: Text("Échec de la validation")),
    //         );
    //       }
    //     },
    //     icon: const Icon(Icons.check),
    //     label: const Text("Signer la requisition"),
    //     style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
    //   );
    // }



    final labels = requisition!['labels'] as List<dynamic>;
    final bool canAddLine = requisition!["submittedAt"] == null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Réquisition #${requisition!["id"]}'),
      ),
      floatingActionButton: canAddLine
          ? FloatingActionButton(
        onPressed: openAddLabelDialog,
        child: const Icon(Icons.add),
        tooltip: "Ajouter une ligne",
      )
          : null,
      body: RefreshIndicator(
        onRefresh: fetchRequisition,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [


            Text("Motif : ${requisition!["motif"]}", style: const TextStyle(fontSize: 18)),
            Text("Devise : ${requisition!["currency"]}"),
            Text("Montant total : ${requisition!["amount"]}"),
            Text("Par : ${requisition!["owner"]['names']}"),


            const SizedBox(height: 20),
            const Text("Lignes :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...labels.map((label) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(label["description"]),
                  subtitle: Text("Prix unitaire : ${label["unitCost"]}, Qté : ${label["quantity"]}"),
                  trailing: Text("Total : ${label["amount"]}"),
                ),
              );
            }),


            if (requisitionDetail!= null
            && requisitionDetail!["submittedAt"] ==null
           // && requisitionDetail!['state'] == 'draft'
            )...[
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  final id = requisitionDetail!['id'];
                  final success = await submitRequisition(id, widget.token); // Assure-toi que `token` est dispo ici

                  if (success) {
                    await fetchRequisition(); // Recharge les données
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Réquisition soumise avec succès!')),
                    );
                    setState(() {}); // Pour rafraîchir l'affichage du bouton
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => MainScreen(initialIndex: 1, toggleTheme: () {  }, isDirector: false,),
                      ),
                          (Route<dynamic> route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la soumission')),
                    );
                  }
                },
                icon: Icon(Icons.send),
                label: Text("Soumettre la réquisition"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],


            //director butons

    if (widget.isDirector && requisitionDetail != null && requisitionDetail!['state'] == 'pending')
    ...[
      ElevatedButton.icon(
        onPressed: () async {
          final id = requisitionDetail!['id'];
          final url = 'https://baadhiteam.com/api/requisitions/$id/opt/sign?signatory=dTime';

          final response = await http.post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer ${widget.token}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({}), // L'API demande un body vide
          );

          if (response.statusCode == 200 || response.statusCode==201) {
            // Recharge les détails
            await fetchRequisition();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Réquisition validée avec succès")),
            );
            setState(() {});
          } else {
            print('Erreur: ${response.statusCode} - ${response.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Échec de la validation")),
            );
          }
        },
        icon: const Icon(Icons.check),
        label: const Text("Signer la requisition"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      )
    ]




          ],
        ),
      ),
    );
  }
}