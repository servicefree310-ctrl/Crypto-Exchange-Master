import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasources/blog_remote_datasource.dart';
import '../../domain/entities/blog_post_entity.dart' as post_ent;
import '../../domain/entities/blog_author_entity.dart' as author_ent;
import '../../data/models/blog_author_model.dart' as auth_model;
import '../../../../../core/errors/failures.dart';

// EVENTS
abstract class AuthorsEvent extends Equatable {
  const AuthorsEvent();
  @override
  List<Object?> get props => [];
}

class AuthorsRequested extends AuthorsEvent {
  const AuthorsRequested({this.includePosts = false});
  final bool includePosts;
  @override
  List<Object?> get props => [includePosts];
}

class AuthorDetailRequested extends AuthorsEvent {
  const AuthorDetailRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class ApplyForAuthorRequested extends AuthorsEvent {
  const ApplyForAuthorRequested(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

// STATES
abstract class AuthorsState extends Equatable {
  const AuthorsState();
  @override
  List<Object?> get props => [];
}

class AuthorsInitial extends AuthorsState {}

class AuthorsLoading extends AuthorsState {}

class AuthorsLoaded extends AuthorsState {
  const AuthorsLoaded(this.authors);
  final List<author_ent.BlogAuthorEntity> authors;
  @override
  List<Object?> get props => [authors];
}

class AuthorLoaded extends AuthorsState {
  const AuthorLoaded(this.author, this.posts);
  final author_ent.BlogAuthorEntity author;
  final List<post_ent.BlogPostEntity> posts;
  @override
  List<Object?> get props => [author, posts];
}

class AuthorsError extends AuthorsState {
  const AuthorsError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}

// BLOC
@injectable
class AuthorsBloc extends Bloc<AuthorsEvent, AuthorsState> {
  AuthorsBloc(this._remote) : super(AuthorsInitial()) {
    on<AuthorsRequested>(_onAuthorsRequested);
    on<AuthorDetailRequested>(_onAuthorDetailRequested);
    on<ApplyForAuthorRequested>(_onApplyForAuthorRequested);
  }
  final BlogRemoteDataSource _remote;

  Future<void> _onAuthorsRequested(
      AuthorsRequested event, Emitter<AuthorsState> emit) async {
    emit(AuthorsLoading());
    try {
      final list = await _remote.getAuthors(includePosts: event.includePosts);
      emit(AuthorsLoaded(list
          .map((m) => (m as auth_model.BlogAuthorModel).toEntity())
          .toList()));
    } catch (e) {
      emit(AuthorsError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onAuthorDetailRequested(
      AuthorDetailRequested event, Emitter<AuthorsState> emit) async {
    emit(AuthorsLoading());
    try {
      final auth_model.BlogAuthorModel model =
          await _remote.getAuthor(event.id) as auth_model.BlogAuthorModel;
      emit(AuthorLoaded(model.toEntity(), [])); // posts not yet mapped
    } catch (e) {
      emit(AuthorsError(ServerFailure(e.toString())));
    }
  }

  Future<void> _onApplyForAuthorRequested(
      ApplyForAuthorRequested event, Emitter<AuthorsState> emit) async {
    try {
      await _remote.applyForAuthor(event.userId);
    } catch (e) {
      // just log
    }
  }
}
