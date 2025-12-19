import 'package:e_commerce/core/theme/app_theme.dart';
import 'package:e_commerce/features/auth/login/login.dart';
import 'package:e_commerce/features/auth/regester/register.dart';
import 'package:e_commerce/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:e_commerce/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:e_commerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:e_commerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:e_commerce/features/cart/presentation/screens/cart_screen.dart';
import 'package:e_commerce/features/navigation_layout/navigation_view.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/cubit/category_cubit.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/repositories/category_repository.dart';
import 'package:e_commerce/features/navigation_layout/tabs/favorite/cubit/favorites_cubit.dart';
import 'package:e_commerce/features/navigation_layout/tabs/favorite/data/repositories/favorites_repository.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/cubit/products/products_cubit.dart';
import 'package:e_commerce/features/products/data/repositories/products_repository_impl.dart';
import 'package:e_commerce/features/products/domain/repositories/products_repository.dart';
import 'package:e_commerce/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CartLocalDataSource>(
          create: (context) => CartLocalDataSourceImpl(),
        ),
        RepositoryProvider<CartRepository>(
          create: (context) => CartRepositoryImpl(
            localDataSource: context.read<CartLocalDataSource>(),
          ),
        ),
        RepositoryProvider<ProductsRepository>(
          create: (context) => ProductsRepositoryImpl(),
        ),
        RepositoryProvider<FavoritesRepository>(
          create: (context) => FavoritesRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CartBloc>(
            create: (context) =>
                CartBloc(cartRepository: context.read<CartRepository>())
                  ..add(LoadCartEvent()), 
          ),
          BlocProvider<ProductsCubit>(
            create: (context) => ProductsCubit(
              productsRepository: context.read<ProductsRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => CategoryCubit(CategoryRepository()),
          ),
          BlocProvider(
            create: (context) => FavoritesCubit(
              context.read<FavoritesRepository>(),
            )..loadFavorites(),
          ),
        ],
        child: MaterialApp(
          title: "E-Commerce",
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getLightThemeData(),
          initialRoute: SplashScreen.routeName,
          routes: {
            SplashScreen.routeName: (ctx) => const SplashScreen(),
            Login.routeName: (ctx) => const Login(),
            SignUp.routeName: (ctx) => const SignUp(),
            NavigationView.routeName: (ctx) => const NavigationView(),
            CartScreen.routeName: (ctx) => const CartScreen(),
          },
        ),
      ),
    );
  }
}
