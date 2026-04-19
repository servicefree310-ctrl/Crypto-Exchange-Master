import 'package:flutter/material.dart';
import '../../domain/entities/wallet_entity.dart';

class WalletCard extends StatelessWidget {
  final WalletEntity wallet;
  final VoidCallback? onTap;
  final bool showBalance;
  final bool isSelected;
  final EdgeInsets? margin;

  const WalletCard({
    super.key,
    required this.wallet,
    this.onTap,
    this.showBalance = true,
    this.isSelected = false,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Card(
        elevation: isSelected ? 6 : 3,
        shadowColor: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.3) : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isSelected ? Border.all(
                color: Theme.of(context).primaryColor,
                width: 2,
              ) : null,
              gradient: isSelected ? LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  Theme.of(context).primaryColor.withValues(alpha: 0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _getCurrencyColor(wallet.currency).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getCurrencyColor(wallet.currency).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: wallet.icon != null
                              ? Image.network(
                                  wallet.icon!,
                                  width: 28,
                                  height: 28,
                                  errorBuilder: (context, error, stackTrace) => _buildCurrencyText(),
                                )
                              : _buildCurrencyText(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wallet.currency.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getTypeColor(wallet.type).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                wallet.type.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getTypeColor(wallet.type),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showBalance)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatBalance(wallet.balance),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: wallet.balance > 0 ? Colors.green[700] : Colors.grey[600],
                              ),
                            ),
                            if (wallet.inOrder > 0) ...[
                              const SizedBox(height: 2),
                              Text(
                                'In Order: ${_formatBalance(wallet.inOrder)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                    ],
                  ),
                  if (showBalance) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Available Balance',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatBalance(wallet.availableBalance),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: wallet.status ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: wallet.status ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  wallet.status ? Icons.check_circle : Icons.cancel,
                                  size: 14,
                                  color: wallet.status ? Colors.green[700] : Colors.red[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  wallet.status ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: wallet.status ? Colors.green[700] : Colors.red[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (wallet.isEcoWallet && wallet.hasMultiChainAddress)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.link,
                              size: 14,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Multi-chain addresses available',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyText() {
    return Text(
      wallet.currency.substring(0, wallet.currency.length >= 3 ? 3 : wallet.currency.length).toUpperCase(),
      style: TextStyle(
        color: _getCurrencyColor(wallet.currency),
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Color _getCurrencyColor(String currency) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    
    final hash = currency.hashCode;
    return colors[hash.abs() % colors.length];
  }

  Color _getTypeColor(WalletType type) {
    switch (type) {
      case WalletType.FIAT:
        return Colors.green;
      case WalletType.SPOT:
        return Colors.blue;
      case WalletType.ECO:
        return Colors.teal;
      case WalletType.FUTURES:
        return Colors.purple;
    }
  }

  String _formatBalance(double balance) {
    if (balance >= 1000000) {
      return '${(balance / 1000000).toStringAsFixed(2)}M';
    } else if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(2)}K';
    } else if (balance >= 1) {
      return balance.toStringAsFixed(2);
    } else {
      return balance.toStringAsFixed(8);
    }
  }
}