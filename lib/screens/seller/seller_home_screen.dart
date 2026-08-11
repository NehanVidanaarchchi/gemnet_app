import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'seller_listings_screen.dart';
import 'add_gem_screen.dart';
import '../chat/chat_list_screen.dart';
import '../shared/profile_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int _index = 0;

  final _tabs = const [
    SellerListingsScreen(),
    ChatListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(child: _tabs[_index]),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Add Gem'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGemScreen())),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Listings'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chats'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
