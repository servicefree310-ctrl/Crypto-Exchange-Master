import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/support_ticket_entity.dart';
import '../../domain/entities/create_ticket_params.dart';
import '../../domain/usecases/get_support_tickets_usecase.dart';
import '../../domain/usecases/create_support_ticket_usecase.dart';

// Events
abstract class SupportTicketsEvent extends Equatable {
  const SupportTicketsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSupportTicketsRequested extends SupportTicketsEvent {
  const LoadSupportTicketsRequested({
    this.page = 1,
    this.search,
    this.status,
    this.importance,
  });

  final int page;
  final String? search;
  final TicketStatus? status;
  final TicketImportance? importance;

  @override
  List<Object?> get props => [page, search, status, importance];
}

class RefreshSupportTicketsRequested extends SupportTicketsEvent {
  const RefreshSupportTicketsRequested();
}

class CreateSupportTicketRequested extends SupportTicketsEvent {
  const CreateSupportTicketRequested(this.params);

  final CreateTicketParams params;

  @override
  List<Object?> get props => [params];
}

class FilterSupportTicketsRequested extends SupportTicketsEvent {
  const FilterSupportTicketsRequested({
    this.search,
    this.status,
    this.importance,
  });

  final String? search;
  final TicketStatus? status;
  final TicketImportance? importance;

  @override
  List<Object?> get props => [search, status, importance];
}

// States
abstract class SupportTicketsState extends Equatable {
  const SupportTicketsState();

  @override
  List<Object?> get props => [];
}

class SupportTicketsInitial extends SupportTicketsState {
  const SupportTicketsInitial();
}

class SupportTicketsLoading extends SupportTicketsState {
  const SupportTicketsLoading();
}

class SupportTicketsLoaded extends SupportTicketsState {
  const SupportTicketsLoaded({
    required this.tickets,
    this.hasReachedMax = false,
    this.isRefreshing = false,
    this.search,
    this.status,
    this.importance,
  });

  final List<SupportTicketEntity> tickets;
  final bool hasReachedMax;
  final bool isRefreshing;
  final String? search;
  final TicketStatus? status;
  final TicketImportance? importance;

  @override
  List<Object?> get props => [
        tickets,
        hasReachedMax,
        isRefreshing,
        search,
        status,
        importance,
      ];

  SupportTicketsLoaded copyWith({
    List<SupportTicketEntity>? tickets,
    bool? hasReachedMax,
    bool? isRefreshing,
    String? search,
    TicketStatus? status,
    TicketImportance? importance,
  }) {
    return SupportTicketsLoaded(
      tickets: tickets ?? this.tickets,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      search: search ?? this.search,
      status: status ?? this.status,
      importance: importance ?? this.importance,
    );
  }
}

class SupportTicketsError extends SupportTicketsState {
  const SupportTicketsError({
    required this.message,
    this.tickets = const [],
  });

  final String message;
  final List<SupportTicketEntity> tickets;

  @override
  List<Object?> get props => [message, tickets];
}

class SupportTicketCreated extends SupportTicketsState {
  const SupportTicketCreated(this.ticket);

  final SupportTicketEntity ticket;

  @override
  List<Object?> get props => [ticket];
}

// BLoC
@injectable
class SupportTicketsBloc
    extends Bloc<SupportTicketsEvent, SupportTicketsState> {
  SupportTicketsBloc(
    this._getSupportTicketsUseCase,
    this._createSupportTicketUseCase,
  ) : super(const SupportTicketsInitial()) {
    on<LoadSupportTicketsRequested>(_onLoadSupportTickets);
    on<RefreshSupportTicketsRequested>(_onRefreshSupportTickets);
    on<CreateSupportTicketRequested>(_onCreateSupportTicket);
    on<FilterSupportTicketsRequested>(_onFilterSupportTickets);
  }

  final GetSupportTicketsUseCase _getSupportTicketsUseCase;
  final CreateSupportTicketUseCase _createSupportTicketUseCase;

  int _currentPage = 1;
  static const int _pageSize = 20;

  Future<void> _onLoadSupportTickets(
    LoadSupportTicketsRequested event,
    Emitter<SupportTicketsState> emit,
  ) async {
    final currentState = state;

    if (event.page == 1) {
      emit(const SupportTicketsLoading());
    }

    final result = await _getSupportTicketsUseCase(
      page: event.page,
      perPage: _pageSize,
      search: event.search,
      status: event.status,
      importance: event.importance,
    );

    result.fold(
      (failure) {
        if (currentState is SupportTicketsLoaded) {
          emit(SupportTicketsError(
            message: failure.message,
            tickets: currentState.tickets,
          ));
        } else {
          emit(SupportTicketsError(message: failure.message));
        }
      },
      (tickets) {
        final bool hasReachedMax = tickets.length < _pageSize;

        if (event.page == 1 || currentState is! SupportTicketsLoaded) {
          emit(SupportTicketsLoaded(
            tickets: tickets,
            hasReachedMax: hasReachedMax,
            search: event.search,
            status: event.status,
            importance: event.importance,
          ));
        } else {
          // Append to existing tickets for pagination
          final allTickets =
              List<SupportTicketEntity>.from(currentState.tickets)
                ..addAll(tickets);

          emit(currentState.copyWith(
            tickets: allTickets,
            hasReachedMax: hasReachedMax,
          ));
        }

        _currentPage = event.page;
      },
    );
  }

  Future<void> _onRefreshSupportTickets(
    RefreshSupportTicketsRequested event,
    Emitter<SupportTicketsState> emit,
  ) async {
    final currentState = state;

    if (currentState is SupportTicketsLoaded) {
      emit(currentState.copyWith(isRefreshing: true));

      add(LoadSupportTicketsRequested(
        page: 1,
        search: currentState.search,
        status: currentState.status,
        importance: currentState.importance,
      ));
    } else {
      add(const LoadSupportTicketsRequested(page: 1));
    }
  }

  Future<void> _onCreateSupportTicket(
    CreateSupportTicketRequested event,
    Emitter<SupportTicketsState> emit,
  ) async {
    final result = await _createSupportTicketUseCase(event.params);

    result.fold(
      (failure) => emit(SupportTicketsError(message: failure.message)),
      (ticket) {
        emit(SupportTicketCreated(ticket));

        // Refresh the tickets list
        add(const RefreshSupportTicketsRequested());
      },
    );
  }

  Future<void> _onFilterSupportTickets(
    FilterSupportTicketsRequested event,
    Emitter<SupportTicketsState> emit,
  ) async {
    add(LoadSupportTicketsRequested(
      page: 1,
      search: event.search,
      status: event.status,
      importance: event.importance,
    ));
  }

  void loadMoreTickets() {
    final currentState = state;
    if (currentState is SupportTicketsLoaded && !currentState.hasReachedMax) {
      add(LoadSupportTicketsRequested(
        page: _currentPage + 1,
        search: currentState.search,
        status: currentState.status,
        importance: currentState.importance,
      ));
    }
  }
}
