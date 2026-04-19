import 'package:flutter/material.dart';

enum WalletTab {
  wallets,
  deposit,
  withdraw,
  transfer,
  history,
}

class WalletNavigationTabs extends StatelessWidget {
  final WalletTab activeTab;
  final Function(WalletTab) onTabChanged;

  const WalletNavigationTabs({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Tab bar
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTab(
                    WalletTab.wallets, 'Wallets', Icons.account_balance_wallet),
                _buildTab(WalletTab.deposit, 'Deposit', Icons.arrow_downward),
                _buildTab(WalletTab.withdraw, 'Withdraw', Icons.arrow_upward),
                _buildTab(WalletTab.transfer, 'Transfer', Icons.swap_horiz),
                _buildTab(WalletTab.history, 'History', Icons.history),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(WalletTab tab, String label, IconData icon) {
    final isActive = activeTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6C5CE7) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey,
                size: 16,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder widgets for non-wallet tabs
class DepositTabContent extends StatelessWidget {
  const DepositTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_downward,
            size: 64,
            color: Color(0xFF6C5CE7),
          ),
          SizedBox(height: 16),
          Text(
            'Deposit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add funds to your wallets',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Coming Soon',
            style: TextStyle(
              color: Color(0xFF6C5CE7),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class WithdrawTabContent extends StatelessWidget {
  const WithdrawTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_upward,
            size: 64,
            color: Color(0xFFEF4444),
          ),
          SizedBox(height: 16),
          Text(
            'Withdraw',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Withdraw funds from your wallets',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Coming Soon',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class TransferTabContent extends StatelessWidget {
  const TransferTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz,
            size: 64,
            color: Color(0xFFF59E0B),
          ),
          SizedBox(height: 16),
          Text(
            'Transfer',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Transfer funds between wallets',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Coming Soon',
            style: TextStyle(
              color: Color(0xFFF59E0B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryTabContent extends StatelessWidget {
  const HistoryTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Color(0xFF8B5CF6),
          ),
          SizedBox(height: 16),
          Text(
            'History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'View your transaction history',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Coming Soon',
            style: TextStyle(
              color: Color(0xFF8B5CF6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
