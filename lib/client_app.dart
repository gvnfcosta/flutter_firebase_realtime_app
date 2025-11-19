import 'package:flutter/material.dart';

import 'src/config/app_routes.dart';
import 'src/config/app_theme.dart';
import 'src/screens/client/client_detail_screen.dart';
import 'src/screens/home/home_screen.dart';
import 'src/screens/sign_in/signin_screen.dart';
import 'src/screens/sign_in/splash_screen.dart';
import 'src/screens/user/user_form_screen.dart';

class ClientApp extends StatelessWidget {
  const ClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Client App',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      initialRoute: AppRoutes.home,
      // initialRoute: AppRoutes.signIn,
      // initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.splash:
            return _buildRoute(const SplashScreen());

          case AppRoutes.signIn:
            return _buildRoute(const SignInScreen());

          case AppRoutes.home:
            return _buildRoute(const HomeScreen());

          case AppRoutes.userForm:
            final uid = settings.arguments as String?;
            if (uid == null || uid.isEmpty) {
              throw ArgumentError('UID obrigatório para UserFormScreen');
            }
            return _buildRoute(UserFormScreen(uid: uid));

          case AppRoutes.clientDetail:
            final args = settings.arguments as Map<String, dynamic>?;
            final userCode = args?['userCode'];
            final clientId = args?['clientId'];
            if (userCode == null || clientId == null) {
              throw ArgumentError(
                'Parâmetros obrigatórios: userCode e clientId',
              );
            }
            return _buildRoute(
              ClientDetailScreen(userCode: userCode, clientId: clientId),
            );

          default:
            // 🔸 fallback seguro — evita travar caso a rota seja inválida
            return _buildRoute(const SplashScreen());
        }
      },
    );
  }

  /// 🔹 Função auxiliar para manter consistência de transição
  MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
