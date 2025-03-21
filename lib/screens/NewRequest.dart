import 'package:flutter/material.dart';

class NewRequestScreen extends StatefulWidget {
  const NewRequestScreen({super.key});

  @override
  _NewRequestScreenState createState() => _NewRequestScreenState();
}

class _NewRequestScreenState extends State<NewRequestScreen> {
  final TextEditingController _motifController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  String? _selectedDepartment;
  String? _selectedBudgetLine;
  final List<String> _departments = ['Finances', 'Ressources Humaines', 'Logistique'];
  final List<String> _budgetLines = ['Matériel', 'Transport', 'Autre'];

  void _previewRequest() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aperçu de la Réquisition', style: TextStyle(color: Colors.blue)),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Motif: ${_motifController.text}', style: const TextStyle(color: Colors.blue)),
              Text('Département: $_selectedDepartment', style: const TextStyle(color: Colors.blue)),
              Text('Ligne budgétaire: ${_selectedBudgetLine ?? "Non spécifiée"}', style: const TextStyle(color: Colors.blue)),
              Text('Montant: ${_montantController.text} USD', style: const TextStyle(color: Colors.blue)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Modifier', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Logique de soumission
              },
              child: const Text('Soumettre', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Nouvelle Réquisition')),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                children: [
                TextField(controller: _motifController, decoration: const InputDecoration(labelText: 'Motif', labelStyle: TextStyle(color: Colors.blue))),
            DropdownButtonFormField(
            items: _departments.map((dep) => DropdownMenuItem(value: dep, child: Text(dep, style: const TextStyle(color: Colors.blue)))).toList(),
    onChanged: (value) => setState(() => _selectedDepartment = value),
    decoration: const InputDecoration(labelText: 'Département', labelStyle: TextStyle(color: Colors.blue)),
    ),
    TextField(controller: _montantController, decoration: const InputDecoration(labelText: 'Montant (USD)', labelStyle: TextStyle(color: Colors.blue)), keyboardType: TextInputType.number),
    const SizedBox(height: 20),
    ElevatedButton(onPressed: _previewRequest, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('Prévisualiser', style: TextStyle(color: Colors.white))),
    ],
    ),
    ),
    );
  }
}
