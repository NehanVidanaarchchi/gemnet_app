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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.diamond_outlined), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.verified_outlined), label: 'Certificate'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
