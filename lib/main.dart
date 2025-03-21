import 'package:baadhi_team/screens/AccountScreen.dart';
import 'package:baadhi_team/screens/Dash.dart';
import 'package:baadhi_team/screens/LoginScreen.dart';
import 'package:flutter/material.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'BaadhiTeam',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home:_isAuthenticated ? MainScreen(toggleTheme: _toggleTheme, isDirector: _isDirector) : LoginScreen(onLogin: _login),
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDirector;
  const MainScreen({super.key, required this.toggleTheme,required this.isDirector});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DashboardScreen(),
      RequestFormScreen(isDirector: widget.isDirector),
      const AccountScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Image.asset('assets/images/LOGO.png', height: 40)),
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
      body: pages[_selectedIndex],
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
      ),
    );
  }
}




