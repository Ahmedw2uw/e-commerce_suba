import 'package:e_commerce/core/theme/app_theme.dart';
import 'package:e_commerce/core/widgets/cart_screen.dart';
import 'package:e_commerce/features/auth/login/login.dart';
import 'package:e_commerce/features/auth/regester/register.dart';
import 'package:e_commerce/features/navigation_layout/navigation_view.dart';
import 'package:e_commerce/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
