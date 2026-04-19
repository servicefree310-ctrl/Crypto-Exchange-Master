import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';
import 'package:mobile/injection/injection.dart';

import '../bloc/investors_cubit.dart';
import '../../domain/entities/investor_entity.dart';

class CreatorInvestorsPage extends StatefulWidget {
  const CreatorInvestorsPage({super.key});

  @override
  State<CreatorInvestorsPage> createState() => _CreatorInvestorsPageState();
}

class _CreatorInvestorsPageState extends State<CreatorInvestorsPage> {
  final _searchController = TextEditingController();
  String _sortField = 'lastTransactionDate';
  bool _sortAscending = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return BlocProvider(
      create: (_) => getIt<InvestorsCubit>()..fetchInvestors(),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        body: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: context.colors.surface,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Text(
                  'Investors',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.orangeAccent,
                        context.orangeAccent.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      // Stats in header
                      Positioned(
                        bottom: 60,
                        left: 16,
                        right: 16,
                        child: BlocBuilder<InvestorsCubit, InvestorsState>(
                          builder: (context, state) {
                            if (state is InvestorsLoaded) {
                              final totalInvestors = state.investors.length;
                              final totalRaised = state.investors.fold<double>(
                                0,
                                (sum, investor) => sum + investor.totalCost,
                              );
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildHeaderStat(
                                    'Total Investors',
                                    totalInvestors.toString(),
                                    Icons.people,
                                  ),
                                  _buildHeaderStat(
                                    'Total Raised',
                                    '\$${_formatAmount(totalRaised)}',
                                    Icons.attach_money,
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.sort,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: _showSortOptions,
                ),
              ],
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search investors...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: context.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              // TODO: Implement search
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    // TODO: Implement search with debounce
                  },
                ),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: BlocBuilder<InvestorsCubit, InvestorsState>(
                builder: (context, state) {
                  if (state is InvestorsLoading) {
                    return _buildLoadingState();
                  }

                  if (state is InvestorsError) {
                    return _buildErrorState(context, state.message);
                  }

                  if (state is InvestorsLoaded) {
                    if (state.investors.isEmpty) {
                      return _buildEmptyState(context);
                    }
                    return _buildInvestorsList(context, state.investors);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(50),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: context.colors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading investors',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                context.read<InvestorsCubit>().fetchInvestors();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = context.isDarkMode;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: context.orangeAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 60,
                color: context.orangeAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Investors Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your investors will appear here once\nthey start investing in your tokens',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestorsList(
      BuildContext context, List<InvestorEntity> investors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary Card
          _buildSummaryCard(context, investors),
          const SizedBox(height: 16),

          // Investors List
          ...investors.map((investor) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildInvestorCard(context, investor),
              )),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, List<InvestorEntity> investors) {
    final isDark = context.isDarkMode;
    final totalInvestors = investors.length;
    final totalRaised =
        investors.fold<double>(0, (sum, investor) => sum + investor.totalCost);
    final totalTokens = investors.fold<double>(
        0, (sum, investor) => sum + investor.totalTokens);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.orangeAccent,
            context.orangeAccent.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.orangeAccent.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Investment Summary',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Investors',
                totalInvestors.toString(),
                Icons.people,
              ),
              _buildSummaryItem(
                'Total Raised',
                '\$${_formatAmount(totalRaised)}',
                Icons.attach_money,
              ),
              _buildSummaryItem(
                'Tokens Sold',
                _formatAmount(totalTokens),
                Icons.token,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildInvestorCard(BuildContext context, InvestorEntity investor) {
    final isDark = context.isDarkMode;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to investor detail
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Investor Info Row
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.orangeAccent.withValues(alpha: 0.1),
                        border: Border.all(
                          color: context.orangeAccent.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: investor.avatar != null
                          ? ClipOval(
                              child: Image.network(
                                investor.avatar!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildAvatarPlaceholder(investor),
                              ),
                            )
                          : _buildAvatarPlaceholder(investor),
                    ),
                    const SizedBox(width: 12),

                    // Name and Token Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            investor.fullName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (investor.offeringIcon != null)
                                Container(
                                  width: 16,
                                  height: 16,
                                  margin: const EdgeInsets.only(right: 4),
                                  child: Image.network(
                                    investor.offeringIcon!,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox.shrink(),
                                  ),
                                ),
                              Text(
                                '${investor.offeringSymbol} • ${investor.offeringName}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Investment Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${_formatAmount(investor.totalCost)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: context.priceUpColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${_formatAmount(investor.totalTokens)} tokens',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
                const SizedBox(height: 8),

                // Date and Status Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(investor.lastTransactionDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    if (investor.rejectedCost > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.priceDownColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Rejected: \$${_formatAmount(investor.rejectedCost)}',
                          style: TextStyle(
                            color: context.priceDownColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(InvestorEntity investor) {
    return Center(
      child: Text(
        investor.fullName.substring(0, 2).toUpperCase(),
        style: TextStyle(
          color: context.orangeAccent,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  void _showSortOptions() {
    final isDark = context.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sort By',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildSortOption(
              'Date',
              'lastTransactionDate',
              Icons.calendar_today,
            ),
            _buildSortOption(
              'Investment Amount',
              'totalCost',
              Icons.attach_money,
            ),
            _buildSortOption(
              'Token Amount',
              'totalTokens',
              Icons.token,
            ),
            _buildSortOption(
              'Investor Name',
              'name',
              Icons.person,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String field, IconData icon) {
    final isSelected = _sortField == field;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? context.colors.primary : null,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? context.colors.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(
              _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: context.colors.primary,
            )
          : null,
      onTap: () {
        setState(() {
          if (_sortField == field) {
            _sortAscending = !_sortAscending;
          } else {
            _sortField = field;
            _sortAscending = false;
          }
        });
        Navigator.pop(context);
        // TODO: Implement sorting
      },
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).round()} weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
