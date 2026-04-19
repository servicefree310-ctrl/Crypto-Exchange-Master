import 'package:flutter/material.dart';
import '../theme.dart';
import 'login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              color: AppColors.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(Icons.person, size: 28, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Guest', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.fg)),
                    SizedBox(height: 2),
                    Text('Sign in to access your account', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  ])),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: const Text('Login'),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            ..._sections(),
          ],
        ),
      ),
    );
  }

  List<Widget> _sections() {
    final items = <Map<String, dynamic>>[
      {'icon': Icons.verified_user, 'label': 'KYC Verification'},
      {'icon': Icons.security, 'label': 'Security · 2FA / Biometric'},
      {'icon': Icons.devices, 'label': 'Devices'},
      {'icon': Icons.workspace_premium, 'label': 'VIP Tier'},
      {'icon': Icons.savings, 'label': 'Earn'},
      {'icon': Icons.share, 'label': 'Refer & Earn'},
      {'icon': Icons.receipt_long, 'label': 'Transactions'},
      {'icon': Icons.payments, 'label': 'Fees · Maker / Taker'},
      {'icon': Icons.gavel, 'label': 'Legal'},
      {'icon': Icons.help_outline, 'label': 'Help & Support'},
    ];
    return items.map((it) => Card(
      color: AppColors.card,
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: AppColors.border)),
      child: ListTile(
        leading: Icon(it['icon'] as IconData, color: AppColors.primary),
        title: Text(it['label'] as String, style: const TextStyle(color: AppColors.fg, fontWeight: FontWeight.w600, fontSize: 14)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
        onTap: () {},
      ),
    )).toList();
  }
}
