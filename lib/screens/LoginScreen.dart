

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ApiService apiService = ApiService();
  bool isLoading = false;

  void _login() async {
    setState(() {
      isLoading = true;
    });

    bool success = await apiService.login(
      usernameController.text,
      passwordController.text,
    );

    setState(() {
      isLoading = false;
    });

    if (success) {
      // Récupérer les rôles de l'utilisateur
      Map<String, dynamic> userInfo = await apiService.getUserInfo();
      bool isDirector = userInfo['roles'].contains('ROLE_DIRECTOR');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(isDirector: isDirector, toggleTheme: () {  }, initialIndex: 0,)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de connexion. Vérifiez vos identifiants.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Image.asset('assets/images/BAADHI_TEAMLOGO-removebg-preview.png', height: 40)),
              SizedBox(height:30 ,),

              Text('Connexion', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
              SizedBox(height: 20),

        TextField(
          controller: usernameController,
             decoration: const InputDecoration(labelText: 'Email ou numero de telephone', border: OutlineInputBorder()),
           ),
           SizedBox(height: 25),

              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Mot de passe", border: OutlineInputBorder()),
                obscureText: false,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _login,
                child: const Text("Se connecter",style: TextStyle(color: Colors.black),),
              ),
            ],
          ),
        ),
      )
    );
  }
}