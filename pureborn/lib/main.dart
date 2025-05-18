import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/purchase_provider.dart';
import 'providers/day_counter_provider.dart';
import 'screens/login_screen.dart';
import 'screens/purchase_list_screen.dart';
import 'screens/day_counter_screen.dart';
import 'screens/product_list_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/raw_material_screen.dart';
import 'screens/purchase_category_screen.dart';
import 'screens/vendor_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'utils/app_theme.dart';
import 'utils/logger.dart';
import 'config/app_config.dart';
import 'services/purchase_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(
          create:
              (_) => PurchaseProvider(
                PurchaseService(
                  baseUrl: AppConfig.apiBaseUrl.replaceFirst('/api', ''),
                ),
              ),
        ),
        ChangeNotifierProvider(create: (_) => DayCounterProvider()),
      ],
      child: MaterialApp(
        title: 'Pureborn',
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/dashboard': (_) => const BottomNavBar(),
          '/purchases': (_) => const PurchaseListScreen(),
          '/day-counter': (_) => const DayCounterScreen(),
          '/products': (_) => const ProductListScreen(),
          '/raw-materials': (_) => const RawMaterialScreen(),
          '/purchase-categories': (_) => const PurchaseCategoryScreen(),
          '/vendor-management': (_) => const VendorScreen(),
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          );
        },
      ),
    );
  }
}
