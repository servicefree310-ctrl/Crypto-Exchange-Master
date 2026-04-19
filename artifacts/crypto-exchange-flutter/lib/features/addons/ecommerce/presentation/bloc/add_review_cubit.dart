import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

// States
abstract class AddReviewState extends Equatable {
  const AddReviewState();

  @override
  List<Object?> get props => [];
}

class AddReviewInitial extends AddReviewState {
  const AddReviewInitial();
}

class AddReviewLoading extends AddReviewState {
  const AddReviewLoading();
}

class AddReviewSuccess extends AddReviewState {
  const AddReviewSuccess();
}

class AddReviewError extends AddReviewState {
  final String message;

  const AddReviewError({required this.message});

  @override
  List<Object> get props => [message];
}

// Cubit
@injectable
class AddReviewCubit extends Cubit<AddReviewState> {
  AddReviewCubit() : super(const AddReviewInitial());

  Future<void> submitReview({
    required String productId,
    required int rating,
    required String comment,
  }) async {
    emit(const AddReviewLoading());

    try {
      // TODO: Implement actual review submission
      // For now, just simulate success
      await Future.delayed(const Duration(seconds: 1));
      emit(const AddReviewSuccess());
    } catch (e) {
      emit(AddReviewError(message: e.toString()));
    }
  }

  void reset() {
    emit(const AddReviewInitial());
  }
}
