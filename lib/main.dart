// lib/main.dart
import 'package:e_commerce/core/theme/app_theme.dart';
import 'package:e_commerce/features/auth/login/login.dart';
import 'package:e_commerce/features/auth/regester/register.dart';
import 'package:e_commerce/features/cart/data/datasources/cart_local_data_source.dart';
import 'package:e_commerce/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:e_commerce/features/cart/data/repostries/cart_repository_impl.dart';
import 'package:e_commerce/features/cart/domain/repositories/cart_repository.dart';
import 'package:e_commerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:e_commerce/features/cart/presentation/screens/cart_screen.dart';
import 'package:e_commerce/features/navigation_layout/navigation_view.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/cubit/category_cubit.dart';
import 'package:e_commerce/features/navigation_layout/tabs/categories/repostry/category_repository.dart';
import 'package:e_commerce/features/navigation_layout/tabs/favorite/cubit/favorites_cubit.dart';
import 'package:e_commerce/features/navigation_layout/tabs/favorite/data/datasource/favorites_remote_data_source.dart';
import 'package:e_commerce/features/products/data/datasource/products_remote_data_source.dart';
import 'package:e_commerce/features/products/data/repositories/products_repository_impl.dart';
import 'package:e_commerce/features/products/domain/repositories/products_repository.dart';
import 'package:e_commerce/features/products/presentation/bloc/products_bloc.dart';
import 'package:e_commerce/features/splash/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/navigation_layout/tabs/favorite/data/repositories/favorites_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Hive للتخزين المحلي
  await Hive.initFlutter();
  // await Hive.openBox('cart_box');

  // تحميل متغيرات البيئة
  await dotenv.load(fileName: ".env");

  // تهيئة Supabase
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
        // ====================
        // CART DEPENDENCIES
        // ====================
        RepositoryProvider<CartRemoteDataSource>(
          create: (context) => CartRemoteDataSourceImpl(
            supabaseClient: Supabase.instance.client,
          ),
        ),
        RepositoryProvider<CartLocalDataSource>(
          create: (context) => CartLocalDataSourceImpl(),
        ),
        RepositoryProvider<CartRepository>(
          create: (context) => CartRepositoryImpl(
            remoteDataSource: context.read<CartRemoteDataSource>(),
            localDataSource: context.read<CartLocalDataSource>(),
          ),
        ),

        // ====================
        // PRODUCTS DEPENDENCIES
        // ====================
        RepositoryProvider<ProductsRepository>(
          create: (context) => ProductsRepositoryImpl(
            remoteDataSource: ProductsRemoteDataSourceImpl(
              supabaseClient: Supabase.instance.client,
            ),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // ====================
          // BLOC PROVIDERS
          // ====================

          // Cart Bloc - مرة واحدة فقط
          BlocProvider<CartBloc>(
            create: (context) =>
                CartBloc(cartRepository: context.read<CartRepository>())
                  ..add(LoadCartEvent()), // تحميل السلة عند بدء التطبيق
          ),

          // Products Bloc
          BlocProvider<ProductsBloc>(
            create: (context) => ProductsBloc(
              productsRepository: context.read<ProductsRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => CategoryCubit(CategoryRepository()),
          ),
          BlocProvider(
            create: (context) => FavoritesCubit(
              FavoritesRepositoryImpl(FavoritesRemoteDataSourceImpl()),
            ),
          ),
        ],
        child: MaterialApp(
          title: "E-Commerce",
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getLightThemeData(),
          initialRoute: SplashScreen.routeName,
          routes: {
            // ====================
            // APP ROUTES
            // ====================
            SplashScreen.routeName: (ctx) => const SplashScreen(),
            Login.routeName: (ctx) => Login(),
            SignUp.routeName: (ctx) => SignUp(),
            NavigationView.routeName: (ctx) => const NavigationView(),
            CartScreen.routeName: (ctx) => const CartScreen(),
          },
        ),
      ),
    );
  }
}
