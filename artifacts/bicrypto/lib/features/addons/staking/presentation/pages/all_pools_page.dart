import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/staking_bloc.dart';
import '../bloc/staking_event.dart';
import '../bloc/staking_state.dart';
import '../widgets/pool_card.dart';
import 'pool_detail_page.dart';

class AllPoolsPage extends StatefulWidget {
  const AllPoolsPage({super.key});

  @override
  State<AllPoolsPage> createState() => _AllPoolsPageState();
}

class _AllPoolsPageState extends State<AllPoolsPage> {
  String? _selectedStatus;
  double _minApr = 0;
  double _maxApr = 100;
  final TextEditingController _tokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Only load data if the current state is not already loaded
    final currentState = context.read<StakingBloc>().state;
    if (currentState is! StakingLoaded) {
      context.read<StakingBloc>().add(const LoadStakingData());
    }
  }

  void _applyFilters() {
    context.read<StakingBloc>().add(LoadStakingData(
          status: _selectedStatus,
          minApr: _minApr,
          maxApr: _maxApr,
          token:
              _tokenController.text.isNotEmpty ? _tokenController.text : null,
        ));
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Pools')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: _selectedStatus,
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All')),
                          DropdownMenuItem(
                              value: 'ACTIVE', child: Text('Active')),
                          DropdownMenuItem(
                              value: 'INACTIVE', child: Text('Inactive')),
                          DropdownMenuItem(
                              value: 'COMING_SOON', child: Text('Coming Soon')),
                        ],
                        onChanged: (v) => setState(() => _selectedStatus = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _tokenController,
                        decoration: const InputDecoration(
                          labelText: 'Token',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('APR Range'),
                    Expanded(
                      child: RangeSlider(
                        values: RangeValues(_minApr, _maxApr),
                        min: 0,
                        max: 100,
                        divisions: 20,
                        labels: RangeLabels(
                          '${_minApr.toStringAsFixed(0)}%',
                          '${_maxApr.toStringAsFixed(0)}%',
                        ),
                        onChanged: (values) {
                          setState(() {
                            _minApr = values.start;
                            _maxApr = values.end;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<StakingBloc, StakingState>(
              builder: (context, state) {
                if (state is StakingLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is StakingLoaded) {
                  final pools = state.pools;
                  if (pools.isEmpty) {
                    return const Center(child: Text('No pools found.'));
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: pools.length,
                      itemBuilder: (context, index) {
                        final pool = pools[index];
                        return PoolCard(
                          pool: pool,
                          onTap: () {
                            // Navigate to pool detail page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider<StakingBloc>.value(
                                  value: context.read<StakingBloc>(),
                                  child: PoolDetailPage(poolId: pool.id),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                } else if (state is StakingError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
