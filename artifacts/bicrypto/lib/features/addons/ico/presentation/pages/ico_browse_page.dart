import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../domain/entities/ico_offering_entity.dart';
import '../bloc/ico_bloc.dart';
import '../bloc/ico_event.dart';
import '../bloc/ico_state.dart';
import '../widgets/ico_card.dart';
import '../widgets/ico_error_state.dart';
import '../widgets/ico_loading_state.dart';
import '../pages/ico_detail_page.dart';

class IcoBrowsePage extends StatefulWidget {
  const IcoBrowsePage({super.key});

  @override
  State<IcoBrowsePage> createState() => _IcoBrowsePageState();
}

class _IcoBrowsePageState extends State<IcoBrowsePage>
    with SingleTickerProviderStateMixin {
  final _sl = GetIt.instance;
  late final TabController _tabController;
  final _scrollController = ScrollController();

  // Pagination
  static const _pageSize = 20;
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _searchQuery = '';
  final List<IcoOfferingEntity> _offerings = [];

  late final IcoBloc _bloc;
  bool _didFirstLoad = false;

  @override
  void initState() {
    super.initState();
    _bloc = _sl<IcoBloc>();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      // Delay refresh until after current frame to ensure BlocProvider exists
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshList());
    });

    _scrollController.addListener(_onScroll);

    // First load after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialLoad());
  }

  @override
  void dispose() {
    _bloc.close();
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  IcoOfferingStatus? _currentStatus() {
    switch (_tabController.index) {
      case 0:
        return IcoOfferingStatus.active;
      case 1:
        return IcoOfferingStatus.upcoming;
      case 2:
        return IcoOfferingStatus.success;
      default:
        return null;
    }
  }

  void _initialLoad() {
    if (_didFirstLoad) return;
    _didFirstLoad = true;
    _bloc.add(
      IcoLoadOfferingsRequested(
        status: _currentStatus(),
        limit: _pageSize,
        offset: 0,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      ),
    );
  }

  void _refreshList() {
    _currentPage = 0;
    _hasMore = true;
    _isLoadingMore = false;
    _offerings.clear();
    _bloc.add(
      IcoLoadOfferingsRequested(
        status: _currentStatus(),
        limit: _pageSize,
        offset: 0,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      ),
    );
  }

  void _loadMore() {
    if (!_hasMore) return;
    _isLoadingMore = true;
    _currentPage += 1;
    _bloc.add(
      IcoLoadOfferingsRequested(
        status: _currentStatus(),
        limit: _pageSize,
        offset: _currentPage * _pageSize,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Browse ICOs'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final result = await showSearch<String?>(
                  context: context,
                  delegate: _IcoSearchDelegate(initialQuery: _searchQuery),
                );
                if (result != null) {
                  setState(() => _searchQuery = result);
                  _refreshList();
                }
              },
            ),
          ],
        ),
        body: BlocConsumer<IcoBloc, IcoState>(
          listener: (context, state) {
            if (state is IcoOfferingsLoaded) {
              _hasMore = state.hasMore;
              _isLoadingMore = false;

              if (_currentPage == 0) {
                _offerings
                  ..clear()
                  ..addAll(state.offerings);
              } else {
                _offerings.addAll(state.offerings);
              }
            }
          },
          builder: (context, state) {
            if (state is IcoLoading && !_isLoadingMore && _offerings.isEmpty) {
              return const IcoLoadingState(showPortfolio: false);
            }
            if (state is IcoError) {
              return IcoErrorState(
                message: state.message,
                onRetry: _refreshList,
              );
            }
            if (_offerings.isEmpty) {
              return const Center(child: Text('No ICOs found'));
            }
            return RefreshIndicator(
              onRefresh: () async => _refreshList(),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _offerings.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _offerings.length) {
                    final item = _offerings[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: IcoCard(
                        offering: item,
                        isCompact: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => IcoDetailPage(
                                offeringId: item.id,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                  // loader at bottom
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
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

class _IcoSearchDelegate extends SearchDelegate<String?> {
  _IcoSearchDelegate({String initialQuery = ''}) {
    query = initialQuery;
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    close(context, query.trim());
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text('Enter keyword to search ICOs'),
    );
  }
}
