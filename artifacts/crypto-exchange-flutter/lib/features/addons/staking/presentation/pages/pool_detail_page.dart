import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/injection/injection.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';
import '../../domain/entities/staking_pool_entity.dart';
import '../../domain/usecases/stake_usecase.dart';
import '../bloc/staking_bloc.dart';
import '../bloc/staking_event.dart';
import '../bloc/staking_state.dart';

/// Detailed analytics and staking page for a specific pool
class PoolDetailPage extends StatefulWidget {
  final String poolId;
  const PoolDetailPage({super.key, required this.poolId});

  @override
  _PoolDetailPageState createState() => _PoolDetailPageState();
}

class _PoolDetailPageState extends State<PoolDetailPage> {
  final TextEditingController _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isStaking = false;
  double _estimatedRewards = 0.0;

  StakingPoolEntity? get pool {
    final stakingState = context.read<StakingBloc>().state;
    if (stakingState is StakingLoaded) {
      try {
        return stakingState.pools.firstWhere((p) => p.id == widget.poolId);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  void _calculateRewards() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (pool != null && amount > 0) {
      // Simple APR calculation
      final dailyRate = pool!.apr / 365 / 100;
      final rewards = amount * dailyRate * pool!.lockPeriod;
      setState(() {
        _estimatedRewards = rewards;
      });
    } else {
      setState(() {
        _estimatedRewards = 0.0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculateRewards);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StakingBloc, StakingState>(
      builder: (context, state) {
        if (state is StakingLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is StakingError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 56,
                      color: context.colors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: context.bodyM,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<StakingBloc>().add(
                              const LoadStakingData(forceRefresh: true),
                            );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (pool == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 56,
                      color: context.textTertiary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pool not found',
                      style: context.h6,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This pool may have been removed or is temporarily unavailable.',
                      style: context.bodyM,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back to pools'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: context.colors.surface,
          body: CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          context.colors.primary,
                          context.colors.primary.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Pool Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: pool!.icon != null
                                ? Image.network(
                                    pool!.icon!,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.token,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  )
                                : const Icon(
                                    Icons.token,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            pool!.name,
                            style: context.h4.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${pool!.apr}% APR',
                              style: context.labelL.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pool Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? const Color(0xFF1A1A1A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              'Lock Period',
                              '${pool!.lockPeriod} days',
                              Icons.lock_clock,
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Minimum Stake',
                              '\$${pool!.minStake.toStringAsFixed(2)}',
                              Icons.remove_circle_outline,
                            ),
                            if (pool!.maxStake != null) ...[
                              const Divider(height: 24),
                              _buildInfoRow(
                                'Maximum Stake',
                                '\$${pool!.maxStake!.toStringAsFixed(2)}',
                                Icons.add_circle_outline,
                              ),
                            ],
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Available',
                              '\$${pool!.availableToStake.toStringAsFixed(2)}',
                              Icons.account_balance_wallet,
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              'Total Staked',
                              '\$${pool!.totalStaked.toStringAsFixed(2)}',
                              Icons.pie_chart,
                            ),
                          ],
                        ),
                      ),

                      if (pool!.description != null &&
                          pool!.description!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                context.colors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  context.colors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: context.colors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'About this pool',
                                    style: context.labelL.copyWith(
                                      color: context.colors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                pool!.description!,
                                style: context.bodyM.copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Stake Form
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.isDarkMode
                              ? const Color(0xFF1A1A1A)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stake Your ${pool!.symbol}',
                                style: context.h5,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Enter an amount and preview estimated rewards before confirming.',
                                style: context.bodyM.copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: InputDecoration(
                                  labelText: 'Amount',
                                  hintText: 'Enter amount to stake',
                                  prefixIcon: const Icon(Icons.attach_money),
                                  suffixText: pool!.symbol,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter an amount';
                                  }
                                  final amount = double.tryParse(value);
                                  if (amount == null || amount <= 0) {
                                    return 'Please enter a valid amount';
                                  }
                                  if (amount < pool!.minStake) {
                                    return 'Minimum stake is \$${pool!.minStake}';
                                  }
                                  if (pool!.maxStake != null &&
                                      amount > pool!.maxStake!) {
                                    return 'Maximum stake is \$${pool!.maxStake}';
                                  }
                                  if (amount > pool!.availableToStake) {
                                    return 'Insufficient available amount in pool';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // Quick amount buttons
                              Row(
                                children: [
                                  _buildQuickAmountButton('25%', 0.25),
                                  const SizedBox(width: 8),
                                  _buildQuickAmountButton('50%', 0.5),
                                  const SizedBox(width: 8),
                                  _buildQuickAmountButton('75%', 0.75),
                                  const SizedBox(width: 8),
                                  _buildQuickAmountButton('MAX', 1.0),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Estimated Rewards
                              if (_estimatedRewards > 0)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: context.priceUpColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: context.priceUpColor
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.trending_up,
                                        color: context.priceUpColor,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Estimated Rewards',
                                              style: context.labelM.copyWith(
                                                color: context.textSecondary,
                                              ),
                                            ),
                                            Text(
                                              '\$${_estimatedRewards.toStringAsFixed(2)}',
                                              style: context.h6.copyWith(
                                                color: context.priceUpColor,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              'After ${pool!.lockPeriod} days',
                                              style: context.labelS.copyWith(
                                                color: context.textTertiary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 20),

                              // Stake Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isStaking ? null : _handleStake,
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isStaking
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Stake ${pool!.symbol}',
                                          style: context.labelL.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: context.colors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.labelS.copyWith(
                  color: context.textSecondary,
                ),
              ),
              Text(
                value,
                style: context.labelL.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountButton(String label, double percentage) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          final maxAmount = pool!.maxStake ?? pool!.availableToStake;
          final amount = maxAmount * percentage;
          _amountController.text = amount.toStringAsFixed(2);
        },
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Future<void> _handleStake() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);

    setState(() => _isStaking = true);

    try {
      final result = await getIt<StakeUseCase>().call(
        StakeParams(
          poolId: pool!.id,
          amount: amount,
        ),
      );

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: context.colors.error,
            ),
          );
        },
        (position) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Staked successfully!'),
              backgroundColor: context.priceUpColor,
            ),
          );
          // Return true to indicate success
          Navigator.of(context).pop(true);
        },
      );
    } finally {
      setState(() => _isStaking = false);
    }
  }
}
