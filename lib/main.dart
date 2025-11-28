import 'package:e_commerce/core/theme/app_theme.dart';
import 'package:e_commerce/core/widgets/cart_screen.dart';
import 'package:e_commerce/features/auth/login/login.dart';
import 'package:e_commerce/features/auth/regester/register.dart';
import 'package:e_commerce/features/navigation_layout/navigation_view.dart';
import 'package:e_commerce/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lfxqndbxnffcbdcchghm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxmeHFuZGJ4bmZmY2JkY2NoZ2htIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE0MDA2OTEsImV4cCI6MjA3Njk3NjY5MX0.oHut5dkd0Wppll10blQhw_PEYGl8XgGO2pWbl0ZFZW8',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "E-Commerce",
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getLightThemeData(),

      initialRoute: SplashScreen.routeName,

      routes: {
        SplashScreen.routeName: (ctx) => const SplashScreen(),
        Login.routeName: (ctx) => Login(),
        SignUp.routeName: (ctx) => SignUp(),
        NavigationView.routeName: (ctx) => const NavigationView(),
        CartScreen.routeName: (ctx) => const CartScreen(),
      },
    );
  }
}
