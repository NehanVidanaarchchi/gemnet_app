import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/app_state.dart';
import 'models/user_model.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/banned_screen.dart';
import 'screens/buyer/buyer_home_screen.dart';
import 'screens/seller/seller_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'widgets/loading_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GemNetApp());
}

Future<FirebaseApp> initializeFirebaseSafely() async {
  try {
    if (Firebase.apps.isNotEmpty) {
      return Firebase.app();
    }

    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      return Firebase.app();
    }

    rethrow;
  }
}

class GemNetApp extends StatelessWidget {
  const GemNetApp({super.key});

  static final Future<FirebaseApp> _firebaseFuture = initializeFirebaseSafely();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GemNet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: FutureBuilder<FirebaseApp>(
        future: _firebaseFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const StartupLoadingScreen();
          }

          if (snapshot.hasError) {
            return StartupErrorScreen(
              error: snapshot.error.toString(),
            );
          }

          return MultiProvider(
            providers: [
              Provider<AuthService>(
                create: (_) => AuthService(),
              ),
              ChangeNotifierProvider<AppState>(
                create: (context) => AppState(
                  context.read<AuthService>(),
                ),
              ),
            ],
            child: const RootRouter(),
          );
        },
      ),
    );
  }
}

class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }

        final firebaseUser = snapshot.data;

        if (firebaseUser == null) {
          return const LoginScreen();
        }

        return Consumer<AppState>(
          builder: (context, appState, _) {
            if (appState.isLoading) {
              return const LoadingScreen();
            }

            final profile = appState.currentUserProfile;

            if (profile == null) {
              return const LoadingScreen();
            }

            if (profile.isBanned) {
              return const BannedScreen();
            }

            switch (profile.role) {
              case UserRole.seller:
                return const SellerHomeScreen();

              case UserRole.admin:
                return const AdminHomeScreen();

              case UserRole.buyer:
                return const BuyerHomeScreen();
            }
          },
        );
      },
    );
  }
}

class StartupLoadingScreen extends StatelessWidget {
  const StartupLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({
    super.key,
    required this.error,
  });

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text(
            'Startup error:\n\n$error',
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}