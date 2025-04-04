import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequisitionLinesScreen extends StatefulWidget {
  final String token;
  final int requisitionId;

  const RequisitionLinesScreen({
    super.key,
    required this.token,
    required this.requisitionId,
  });

  @override
  _RequisitionLinesScreenState createState() => _RequisitionLinesScreenState();
}

class _RequisitionLinesScreenState extends State<RequisitionLinesScreen> {
  List<Map<String, dynamic>> requisitionLines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLines();
  }

  Future<void> fetchLines() async {
    final url = Uri.parse(
        'https://baadhiteam.com/api/labels/${widget.requisitionId}');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
     print("${widget.requisitionId}");
      print('Description: ${data['description']}');
      print('Quantité: ${data['quantity']}');
      print('Montant: ${data['amount']}');
        isLoading = false;
    } else {
      print('❌ Erreur: ${response.statusCode} - ${response.body}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteLine(int lineId) async {
    final url = Uri.parse('https://baadhiteam.com/api/labels/$lineId');

    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 204) {
      setState(() {
        requisitionLines.removeWhere((line) => line['id'] == lineId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ligne supprimée avec succès")),
      );
    } else {
      print('❌ Erreur: ${response.statusCode} - ${response.body}');
    }
  }

  void showAddLineDialog() {
    TextEditingController wordingController = TextEditingController();
    TextEditingController qtyController = TextEditingController();
    TextEditingController unitCostController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Ajouter une ligne"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: wordingController,
                decoration: InputDecoration(labelText: "Désignation"),
              ),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Quantité"),
              ),
              TextField(
                controller: unitCostController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Prix unitaire"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                await addRequisitionLine(
                  wordingController.text,
                  int.parse(qtyController.text),
                  unitCostController.text,
                );
                Navigator.pop(context);
              },
              child: Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  Future<void> addRequisitionLine(
      String wording, int qty, String unitCost) async {
    final url = Uri.parse('https://baadhiteam.com/api/labels');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "description": wording,
        "unitCost": unitCost,
        "quantity": qty,
        "requisition": "/api/requisitions/${widget.requisitionId}",

      }),
    );

    if (response.statusCode == 201 ||response.statusCode==200) {
      fetchLines();
    } else {
      print('❌ Erreur: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lignes de Réquisition")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: requisitionLines.length,
        itemBuilder: (context, index) {
          final line = requisitionLines[index];
          return Card(
            child: ListTile(
              title: Text(line['description']),
              subtitle: Text(
                  "Quantité: ${line['quantity']} | Prix: ${line['unitCost']} USD"),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteLine(line['id']),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddLineDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}