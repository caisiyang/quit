import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'resources/theme.dart';
import 'l10n/app_strings.dart';
import 'screens/surfing_tab.dart';
import 'screens/history_tab.dart';
import 'screens/discover_tab.dart';

void main() {
  runApp(const QuitApp());
}

class QuitApp extends StatelessWidget {
  const QuitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.theme,
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SurfingTab(),
    const HistoryTab(),
    const DiscoverTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.waves),
            label: AppStrings.tabSurfing,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: AppStrings.tabHistory,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: AppStrings.tabDiscover,
          ),
        ],
      ),
    );
  }
}
