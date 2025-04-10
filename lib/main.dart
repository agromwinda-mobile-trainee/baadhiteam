import 'package:baadhi_team/screens/AccountScreen.dart';
import 'package:baadhi_team/screens/Dash.dart';
import 'package:baadhi_team/screens/LoginScreen.dart';
import 'package:baadhi_team/screens/RequestScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
      routes: {
        '/login': (context) => LoginScreen(),
        '/main': (context) => MainScreen(
          initialIndex: 0,
          toggleTheme: () {}, // ou ta fonction réelle
          isDirector: false,
        ),
      },

      debugShowCheckedModeBanner: false,
      title: 'BaadhiTeam',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home:_isAuthenticated ? MainScreen(toggleTheme: _toggleTheme, isDirector: _isDirector, initialIndex: 0,) : const LoginScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDirector;
  final int initialIndex;
  const MainScreen({super.key,required this.initialIndex, required this.toggleTheme,required this.isDirector});

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
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
       DashboardScreen(),
      RequestScreen(isDirector: widget.isDirector),
      const AccountScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Image.asset('assets/images/BAADHI_TEAMLOGO-removebg-preview.png', height: 40)),
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
              PopupMenuItem(value: 'logout', child: const Text('Déconnexion'),
              onTap:()async{
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Déconnexion'),
                    content: Text('Voulez-vous vraiment vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text('Se déconnecter', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.remove("jwt");
                  Navigator.pushReplacementNamed(context, '/login');
                }
              } ,),
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




