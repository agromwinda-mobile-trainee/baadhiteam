import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Compte')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
          const  CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/profil.JPG'),
            ),
          const  SizedBox(height: 10),
           const Text('Nom: célestin saleh', style: TextStyle(fontSize: 18, color: Colors.black)),
           const Text('Email: lehstinsaleh@gmail.com', style: TextStyle(fontSize: 16, color: Colors.black)),
          const  Divider(height: 30, thickness: 1, color: Colors.black),
          const  ListTile(
              leading: Icon(Icons.info, color: Colors.blue),
              title: Text('Version de l\'application', style: TextStyle(color: Colors.black)),
                  subtitle: Text('1.0.0', style: TextStyle(color: Colors.black)),
            ),
            ListTile(
              leading: const Icon(Icons.security, color: Colors.blue),
              title: const Text('Confidentialité et Sécurité', style: TextStyle(color: Colors.black)),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
