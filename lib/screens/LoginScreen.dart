// import 'package:flutter/material.dart';
// import 'package:async/async.dart';
//
// class LoginScreen extends StatelessWidget {
//   final Function(bool) onLogin;
//   LoginScreen({required this.onLogin});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Center(child: Image.asset('assets/images/LOGO.png', height: 40)),
//               SizedBox(height:30 ,),
//
//               Text('Connexion', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
//           SizedBox(height: 20),
//           TextField(
//             decoration: InputDecoration(labelText: 'Email ou numero de telephone', border: OutlineInputBorder()),
//           ),
//           SizedBox(height: 10),
//           TextField(
//             obscureText: true,
//             decoration: InputDecoration(labelText: 'Mot de passe', border: OutlineInputBorder()),
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () => onLogin(false),
//             child: Text('Se connecter',style: TextStyle(color: Colors.black)),
//             ),
//             SizedBox(height: 10),
//             ElevatedButton(
//               onPressed: () => onLogin(true),
//               child: Text('Se connecter en tant que Directeur',style: TextStyle(color: Colors.black),),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.white70),
//             ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


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
        MaterialPageRoute(builder: (context) => MainScreen(isDirector: isDirector, toggleTheme: () {  },)),
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
              Center(child: Image.asset('assets/images/LOGO.png', height: 40)),
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
                obscureText: true,
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