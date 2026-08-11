import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'browse_gems_tab.dart';
import 'certificate_lookup_screen.dart';
import '../chat/chat_list_screen.dart';
import '../shared/profile_screen.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});

  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int _index = 0;

  final _tabs = const [
    BrowseGemsTab(),
    CertificateLookupScreen(embedded: true),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(child: _tabs[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.diamond_outlined), selectedIcon: Icon(Icons.diamond), label: 'Discover'),
          NavigationDestination(icon: Icon(Icons.verified_outlined), selectedIcon: Icon(Icons.verified), label: 'Verify'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chats'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
