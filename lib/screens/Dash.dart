import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
   DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? names;

  String ? lastname;

  String getGreeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bonjour';
    } else if (hour < 18) {
      return 'Bon après-midi';
    } else {
      return 'Bonsoir';
    }
  }

   @override
   void initState() {
     super.initState();
     loadNames();
   }

   Future<void> loadNames() async {
     final prefs = await SharedPreferences.getInstance();
     setState(() {
       names = prefs.getString('firstname') ?? 'Nom inconnu';
       lastname = prefs.getString('lastname') ?? 'inconnu';
     });
   }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${getGreeting()}, $names  $lastname',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Départements'),
              subtitle: const Text('Informations sur les différents départements.'),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Documents Financiers'),
              subtitle: const Text('Gérez et suivez vos documents financiers.'),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Mes Documents'),
              subtitle: const Text('Accédez à vos documents personnels.'),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}