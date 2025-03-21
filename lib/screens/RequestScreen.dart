// import 'package:flutter/material.dart';
// import 'dart:async';
//
// import 'NewRequest.dart';
//
// class RequestFormScreen extends StatelessWidget {
//   final bool isDirector;
//   RequestFormScreen({required this.isDirector});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Réquisitions')),
//       body: ListView(
//         children: [
//                Card(
//                   child: ListTile(
//                     leading: Icon(Icons.pending_actions),
//                     title: Text('Réquisition #1234'),
//                     subtitle: Text('En attente de validation',style: TextStyle(color: Colors.red)),
//                     onTap: (){
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => RequestDetailScreen(isDirector: isDirector),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//
//                 Card(
//                   child: ListTile(
//                     leading: Icon(Icons.check_circle),
//                     title: Text('Réquisition #5678'),
//                     subtitle: Text('Approuvée',style: TextStyle(color: Colors.green),),
//                     onTap:(){
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => RequestDetailScreen(isDirector: isDirector),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//         const  SizedBox(height: 20),
//           Center(child: ElevatedButton(
//             onPressed: isDirector ? null : () { Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => NewRequestScreen(),
//               ),
//             );},
//     child: const Text(' Nouvelle Réquisition',
//                 style: TextStyle(color: Colors.red),),
//           ), ),
//
//
//         ],
//       ),
//     );
//   }
// }
//
// class RequestDetailScreen extends StatelessWidget {
//   final bool isDirector;
//   RequestDetailScreen({required this.isDirector});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Détail Réquisition')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//           const  Text('Noms de l\'employé: celestin saleh'),
//           const    Text('Département: TECHNOLOGIE ET INNOVATION'),
//           const    Text('Montant: 500 USD'),
//           const    Text('Motif: Achat Serveur'),
//           const    Text('Date de soumission: 12 mars 2025'),
//             if (isDirector) ...[
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {},
//                 child: Text('Approuver'),
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               ),
//               SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: () {},
//                 child: Text('Modifier'),
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//               ),
//               SizedBox(height: 10),
//               ElevatedButton(
//                 onPressed: () {},
//                 child: Text('Rejeter'),
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//


import 'package:flutter/material.dart';
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
    List<Map<String, dynamic>> data = await apiService.fetchRequisitions();
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
              title: Text("Montant : \$${req['amount']}"),
              subtitle: Text("Département : ${req['department']}"),
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
              onTap: () {
                // Ouvrir les détails de la réquisition
              },
            ),
          );
        },
      ),
      floatingActionButton: widget.isDirector
          ? null
          : FloatingActionButton(
        onPressed: () {
          // Naviguer vers l'écran de soumission
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}