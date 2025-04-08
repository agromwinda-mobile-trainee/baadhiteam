// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AccountScreen extends StatelessWidget {
//    AccountScreen({super.key});
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Mon Compte')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//           const  CircleAvatar(
//               radius: 50,
//               backgroundImage: AssetImage('assets/images/profil.JPG'),
//             ),
//           const  SizedBox(height: 10),
//            const Text('Nom: célestin saleh', style: TextStyle(fontSize: 18, color: Colors.black)),
//            const Text('Email: lehstinsaleh@gmail.com', style: TextStyle(fontSize: 16, color: Colors.black)),
//           const  Divider(height: 30, thickness: 1, color: Colors.black),
//           const  ListTile(
//               leading: Icon(Icons.info, color: Colors.blue),
//               title: Text('Version de l\'application', style: TextStyle(color: Colors.black)),
//                   subtitle: Text('1.0.0', style: TextStyle(color: Colors.black)),
//             ),
//             ListTile(
//               leading: const Icon(Icons.security, color: Colors.blue),
//               title: const Text('Confidentialité et Sécurité', style: TextStyle(color: Colors.black)),
//               onTap: () {},
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.red),
//               title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
//               onTap: () {},
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String? names;
  String ? lastname;
  String? phone;
  String? email;
  List<String>? roles;
  String? function;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      names = prefs.getString('firstname') ?? 'Nom inconnu';
     lastname = prefs.getString('lastname') ?? 'inconnu';
      phone = prefs.getString('phoneNumber') ?? 'Téléphone inconnu';
      email = prefs.getString('email') ?? 'Email inconnu';
      roles = prefs.getStringList('roles') ?? [];
      function = prefs.getString('functionName') ?? 'Aucune fonction';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil utilisateur'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, size: 80),
                const SizedBox(height: 16),
                buildRow("Nom     ", names),
                buildRow("post-nom", lastname),
                buildRow("Téléphone", phone),
                buildRow("Email    ", email),
                buildRow("Fonction ", function),
                const SizedBox(height: 12),
                const Text("Rôles :", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                roles != null && roles!.isNotEmpty
                    ? Column(
                  children: roles!
                      .map((role) => Text("• $role", style: const TextStyle(fontSize: 14)))
                      .toList(),
                )
                    : const Text("Aucun rôle trouvé"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text("$label : ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? '')),
        ],
      ),
    );
  }
}