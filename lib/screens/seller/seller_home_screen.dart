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
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.black,
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Add Gem'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGemScreen())),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'My Listings'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
