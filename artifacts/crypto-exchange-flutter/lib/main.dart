import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'services/state.dart';
import 'screens/home_screen.dart';

void main() => runApp(const ZebvixApp());

class ZebvixApp extends StatelessWidget {
  const ZebvixApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()..bootstrap()),
        ChangeNotifierProvider(create: (_) => MarketsState()..start()),
        ChangeNotifierProvider(create: (_) => WalletsState()),
      ],
      child: MaterialApp(
        title: 'ZEBVIX Exchange',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        builder: (context, child) {
          return Container(
            color: const Color(0xFF000814),
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ClipRect(child: child ?? const SizedBox.shrink()),
            ),
          );
        },
        home: const _Bootstrap(),
      ),
    );
  }
}

class _Bootstrap extends StatelessWidget {
  const _Bootstrap();
  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthState, WalletsState>(
      builder: (_, auth, wallets, __) {
        if (auth.isLoggedIn && wallets.wallets.isEmpty && !wallets.loading) {
          WidgetsBinding.instance.addPostFrameCallback((_) => wallets.refresh());
        }
        return const HomeScreen();
      },
    );
  }
}
