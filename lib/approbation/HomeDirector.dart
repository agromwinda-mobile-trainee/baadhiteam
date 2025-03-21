import 'package:flutter/material.dart';

import '../screens/AccountScreen.dart';
import '../screens/Dash.dart';
import '../screens/LoginScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isAuthenticated = false;
  bool _isDirector = false;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _login(bool isDirector) {
    setState(() {
      _isAuthenticated = true;
      _isDirector = isDirector;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Réquisitions',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(color: Colors.blue, iconTheme: IconThemeData(color: Colors.white)),

      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(color: Colors.black, iconTheme: IconThemeData(color: Colors.blue)),
      ),
      themeMode: _themeMode,
      home: _isAuthenticated ? MainScreen(toggleTheme: _toggleTheme, isDirector: _isDirector) : LoginScreen(onLogin: _login),
    );
  }
}

class RequestFormScreen extends StatelessWidget {
  final bool isDirector;
  const RequestFormScreen({super.key, required this.isDirector});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réquisitions')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Réquisition #001'),
            subtitle: const Text('Montant: \$1000 - En attente'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RequestDetailScreen(isDirector: isDirector),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: isDirector ? null : () {},
            child: const Text('Nouvelle Réquisition'),
          ),
        ],
      ),
    );
  }
}

class RequestDetailScreen extends StatelessWidget {
  final bool isDirector;
  const RequestDetailScreen({super.key, required this.isDirector});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail Réquisition')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nom du demandeur: Célestin saleh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Département: Finances'),
            const Text('Montant: \$1000'),
            const Text('Motif: Achat de matériel'),
            const Text('Date de soumission: 12/03/2025'),
            if (isDirector) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Approuver'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Modifier'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Rejeter'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDirector;
  const MainScreen({super.key, required this.toggleTheme, required this.isDirector});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const DashboardScreen(),
      RequestFormScreen(isDirector: widget.isDirector),
      const AccountScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Image.asset('assets/logo.png', height: 40)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'theme') {
                widget.toggleTheme();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'langue', child: Text('Langue')),
              const PopupMenuItem(value: 'theme', child: Text('Mode Sombre')),
              const PopupMenuItem(value: 'logout', child: Text('Déconnexion')),
            ],
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Réquisitions'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mon Compte'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
      ),
    );
  }
}
