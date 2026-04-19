import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_review_cubit.dart';

class ReviewFormModal extends StatefulWidget {
  const ReviewFormModal({super.key, required this.productId});

  final String productId;

  @override
  State<ReviewFormModal> createState() => _ReviewFormModalState();
}

class _ReviewFormModalState extends State<ReviewFormModal> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  double _rating = 5;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AddReviewCubit>().submitReview(
          productId: widget.productId,
          rating: _rating.toInt(),
          comment: _commentController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddReviewCubit, AddReviewState>(
      listener: (context, state) {
        if (state is AddReviewSuccess) {
          Navigator.of(context).pop();
        } else if (state is AddReviewError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add Review', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Slider(
                    value: _rating,
                    divisions: 4,
                    min: 1,
                    max: 5,
                    label: _rating.toInt().toString(),
                    onChanged: (value) => setState(() => _rating = value),
                  ),
                  TextFormField(
                    controller: _commentController,
                    decoration: const InputDecoration(labelText: 'Comment'),
                    validator: (val) =>
                        val == null || val.isEmpty ? 'Enter comment' : null,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<AddReviewCubit, AddReviewState>(
                    builder: (context, state) {
                      final loading = state is AddReviewLoading;
                      return ElevatedButton(
                        onPressed: loading ? null : _submit,
                        child: loading
                            ? const CircularProgressIndicator()
                            : const Text('Submit'),
                      );
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
