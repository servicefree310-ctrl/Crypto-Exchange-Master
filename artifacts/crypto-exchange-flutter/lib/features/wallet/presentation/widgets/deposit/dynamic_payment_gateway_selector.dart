import 'package:flutter/material.dart';
import '../../../domain/entities/deposit_gateway_entity.dart';
import '../../../domain/entities/deposit_method_entity.dart';

class DynamicPaymentGatewaySelector extends StatelessWidget {
  const DynamicPaymentGatewaySelector({
    super.key,
    required this.gateways,
    required this.methods,
    required this.currency,
    this.onGatewaySelected,
    this.onMethodSelected,
  });

  final List<DepositGatewayEntity> gateways;
  final List<DepositMethodEntity> methods;
  final String currency;
  final void Function(DepositGatewayEntity gateway)? onGatewaySelected;
  final void Function(DepositMethodEntity method)? onMethodSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Gateways Section
        if (gateways.isNotEmpty) ...[
          Text(
            'Payment Gateways',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...gateways.map((gateway) => _buildGatewayCard(context, gateway)),
          const SizedBox(height: 24),
        ],

        // Custom Deposit Methods Section
        if (methods.isNotEmpty) ...[
          Text(
            'Deposit Methods',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...methods.map((method) => _buildMethodCard(context, method)),
        ],
      ],
    );
  }

  Widget _buildGatewayCard(BuildContext context, DepositGatewayEntity gateway) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onGatewaySelected?.call(gateway),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Gateway Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getGatewayColor(gateway.alias),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getGatewayIcon(gateway.alias),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Gateway Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gateway.name ?? 'Payment Gateway',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (gateway.description.isNotEmpty == true)
                        Text(
                          gateway.description ?? '',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),

                      // Fee Information
                      Row(
                        children: [
                          if ((gateway.fixedFee ?? 0) > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Fee: ${(gateway.fixedFee ?? 0).toStringAsFixed(2)} $currency',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if ((gateway.percentageFee ?? 0) > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${(gateway.percentageFee ?? 0).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard(BuildContext context, DepositMethodEntity method) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onMethodSelected?.call(method),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Method Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    color: Color(0xFF6C5CE7),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Method Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.title ?? 'Deposit Method',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if ((method.instructions ?? '').isNotEmpty)
                        Text(
                          method.instructions ?? '',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),

                      // Amount Range & Fee
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${method.minAmount ?? 0} - ${method.maxAmount ?? 0} $currency',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if ((method.fixedFee ?? 0) > 0 ||
                              (method.percentageFee ?? 0) > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Fee: ${method.fixedFee ?? 0}${(method.percentageFee ?? 0) > 0 ? ' + ${method.percentageFee}%' : ''}',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withValues(alpha: 0.4),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getGatewayColor(String? alias) {
    switch ((alias ?? '').toLowerCase()) {
      case 'stripe':
        return const Color(0xFF6772E5);
      case 'paypal':
        return const Color(0xFF0070BA);
      default:
        return const Color(0xFF6C5CE7);
    }
  }

  IconData _getGatewayIcon(String? alias) {
    switch ((alias ?? '').toLowerCase()) {
      case 'stripe':
        return Icons.credit_card;
      case 'paypal':
        return Icons.payment;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
