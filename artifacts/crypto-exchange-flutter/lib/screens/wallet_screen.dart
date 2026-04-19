import 'package:flutter/material.dart';
import '../theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet', style: TextStyle(fontWeight: FontWeight.w800))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              color: AppColors.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Total Equity', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  const SizedBox(height: 4),
                  const Text('\$0.00', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.fg)),
                  const SizedBox(height: 4),
                  const Text('≈ ₹0.00', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: _btn(Icons.add, 'Deposit', AppColors.success, () {})),
                    const SizedBox(width: 8),
                    Expanded(child: _btn(Icons.remove, 'Withdraw', AppColors.danger, () {})),
                    const SizedBox(width: 8),
                    Expanded(child: _btn(Icons.swap_horiz, 'Transfer', AppColors.primary, () {})),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text('Assets', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.fg, fontSize: 14)),
            ),
            Card(
              color: AppColors.card,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
              child: const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Column(children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 36, color: AppColors.muted),
                    SizedBox(height: 8),
                    Text('Login to view your assets', style: TextStyle(color: AppColors.muted)),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, String label, Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 18),
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}
