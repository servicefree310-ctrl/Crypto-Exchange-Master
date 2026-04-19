import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../services/state.dart';
import 'login_screen.dart';
import 'kyc_screen.dart';
import 'security_screen.dart';
import 'fees_screen.dart';
import 'refer_screen.dart';
import 'banks_screen.dart';
import 'orders_screen.dart';
import 'earn_screen.dart';
import 'transfer_screen.dart';
import 'deposit_screen.dart';
import 'withdraw_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final u = auth.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Account', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(12), children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
          child: Row(children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(26)),
                child: const Icon(Icons.person, size: 26, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(u?['name']?.toString() ?? u?['email']?.toString() ?? 'Guest', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.fg)),
              const SizedBox(height: 2),
              Text(u?['email']?.toString() ?? 'Sign in to access your account', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ])),
            if (auth.isLoggedIn)
              IconButton(icon: const Icon(Icons.logout, color: AppColors.danger), onPressed: () => auth.logout())
            else
              FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.primary), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), child: const Text('Login')),
          ]),
        ),
        const SizedBox(height: 14),
        if (auth.isLoggedIn) ...[
          _section(context, 'Trading', [
            (Icons.history, 'My Orders', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()))),
            (Icons.swap_horiz, 'Transfer', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferScreen()))),
            (Icons.add_circle_outline, 'Deposit', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DepositScreen()))),
            (Icons.outbox, 'Withdraw', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawScreen()))),
            (Icons.savings, 'Earn', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EarnScreen()))),
          ]),
          const SizedBox(height: 12),
          _section(context, 'Account', [
            (Icons.verified_user, 'KYC Verification', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KycScreen()))),
            (Icons.security, 'Security · 2FA', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityScreen()))),
            (Icons.account_balance, 'Bank Accounts', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BanksScreen()))),
            (Icons.payments, 'Trading Fees · VIP', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeesScreen()))),
            (Icons.share, 'Refer & Earn', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferScreen()))),
          ]),
        ] else ...[
          _section(context, 'Explore', [
            (Icons.workspace_premium, 'VIP Tier & Fees', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeesScreen()))),
            (Icons.savings, 'Earn Products', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EarnScreen()))),
          ]),
        ],
        const SizedBox(height: 12),
        _section(context, 'About', [
          (Icons.gavel, 'Legal · T&C · Privacy', () {}),
          (Icons.help_outline, 'Help & Support', () {}),
        ]),
      ])),
    );
  }

  Widget _section(BuildContext context, String title, List<(IconData, String, VoidCallback)> items) {
    return Container(
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
        ),
        ...items.map((it) => ListTile(
          dense: true,
          leading: Icon(it.$1, color: AppColors.primary, size: 22),
          title: Text(it.$2, style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.w600, fontSize: 14)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.muted, size: 20),
          onTap: it.$3,
        )),
      ]),
    );
  }
}
