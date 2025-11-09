import 'package:flutter/material.dart';
import 'package:flutter_firebase_realtime_app/providers/user_provider.dart';
import 'package:flutter_firebase_realtime_app/src/common/custom_widgets.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_colors.dart';
import 'package:flutter_firebase_realtime_app/src/config/app_data.dart';
import 'package:flutter_firebase_realtime_app/src/screens/user/user_detail_screen.dart';
import 'package:flutter_firebase_realtime_app/src/tabs/client_tab.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tenta acessar o provider de forma segura
    final userProvider = context.watch<UserProvider?>();
    final user = userProvider?.user;

    if (userProvider == null || user == null) {
      // Provider ainda não inicializado ou dados do usuário não carregados
      return const Scaffold(body: Center(child: CustomProgressIndicator()));
    }

    // Define abas
    final List<Widget> tabs = [const ClientTab(), const UserDetailScreen()];

    // Define itens da bottom bar
    final List<BottomNavigationBarItem> navItems = const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: clientTitle),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Fundo com logo (transparente)
          if (user.logoUrl.isNotEmpty)
            Center(
              child: Opacity(
                opacity: 0.05,
                child: Image.network(
                  user.logoUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

          // Conteúdo principal (tabs)
          PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: tabs,
          ),
        ],
      ),

      // Barra inferior de navegação
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
            pageController.jumpToPage(index);
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color.lerp(
          AppColors.appBarBackground,
          Colors.black,
          0.5,
        ),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withAlpha(120),
        selectedFontSize: 15,
        unselectedFontSize: 13,
        items: navItems,
      ),
    );
  }
}
