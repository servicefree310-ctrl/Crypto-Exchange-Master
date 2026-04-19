import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/ico_bloc.dart';
import '../bloc/ico_event.dart';
import '../bloc/ico_state.dart';
import '../widgets/ico_transaction_card.dart';
import '../widgets/ico_error_state.dart';
import '../widgets/ico_loading_state.dart';
import '../../domain/entities/ico_portfolio_entity.dart';
import '../pages/ico_detail_page.dart';

class IcoTransactionsPage extends StatefulWidget {
  const IcoTransactionsPage({super.key});

  @override
  State<IcoTransactionsPage> createState() => _IcoTransactionsPageState();
}

class _IcoTransactionsPageState extends State<IcoTransactionsPage> {
  late final IcoBloc _bloc;
  final _scrollController = ScrollController();

  int _page = 0;
  final int _pageSize = 20;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final List<IcoTransactionEntity> transactions = [];

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.instance<IcoBloc>();
    _fetch();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _bloc.close();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetch() {
    _bloc.add(IcoLoadTransactionsRequested(
        limit: _pageSize, offset: _page * _pageSize));
  }

  void _onScroll() {
    if (_isLoadingMore || !_hasMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _isLoadingMore = true;
      _page += 1;
      _fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: const Text('ICO Transactions')),
        body: BlocConsumer<IcoBloc, IcoState>(
          listener: (context, state) {
            if (state is IcoTransactionsLoaded) {
              if (_page == 0) {
                transactions
                  ..clear()
                  ..addAll(state.transactions);
              } else {
                transactions.addAll(state.transactions);
              }
              _hasMore = state.hasMore;
              _isLoadingMore = false;
            }
          },
          builder: (context, state) {
            if (state is IcoLoading && transactions.isEmpty) {
              return const IcoLoadingState(showPortfolio: false);
            }
            if (state is IcoError && transactions.isEmpty) {
              return IcoErrorState(
                message: state.message,
                onRetry: () {
                  _page = 0;
                  _fetch();
                },
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                _page = 0;
                _fetch();
              },
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: transactions.length + (_hasMore ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= transactions.length) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  final tx = transactions[index];
                  return IcoTransactionCard(
                    transaction: tx,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IcoDetailPage(
                            offeringId: tx.offeringId,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
