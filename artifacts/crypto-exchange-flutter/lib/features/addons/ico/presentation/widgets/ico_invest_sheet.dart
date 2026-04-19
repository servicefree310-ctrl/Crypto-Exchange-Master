import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/ico_offering_entity.dart';
import '../bloc/ico_bloc.dart';
import '../bloc/ico_event.dart';
import '../bloc/ico_state.dart';

class IcoInvestSheet extends StatefulWidget {
  const IcoInvestSheet({super.key, required this.offering});

  final IcoOfferingEntity offering;

  @override
  State<IcoInvestSheet> createState() => _IcoInvestSheetState();
}

class _IcoInvestSheetState extends State<IcoInvestSheet> {
  final _amountController = TextEditingController();
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Invest in ${widget.offering.symbol}',
                  style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (USD)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter amount';
                  final value = double.tryParse(v);
                  if (value == null || value <= 0) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Wallet address',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter wallet address';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm Investment'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final address = _addressController.text.trim();

    setState(() => _submitting = true);

    final bloc = context.read<IcoBloc>();
    bloc.add(IcoCreateInvestmentRequested(
      offeringId: widget.offering.id,
      amount: amount,
      walletAddress: address,
    ));

    // Listen once for result
    late final StreamSubscription sub;
    sub = bloc.stream.listen((state) {
      if (state is IcoInvestmentCreated || state is IcoError) {
        sub.cancel();
        if (!mounted) return;
        Navigator.pop(context);
        if (state is IcoInvestmentCreated) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Investment request submitted successfully')));
        } else if (state is IcoError) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      }
    });
  }
}
