import 'package:flutter/material.dart';
// ignore_for_file: deprecated_member_use
import '../../../../../../core/theme/global_theme_extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/matching/guided_matching_bloc.dart';
import '../../bloc/matching/guided_matching_event.dart';
import '../../bloc/matching/guided_matching_state.dart';
import '../../bloc/payment_methods/payment_methods_bloc.dart';
import '../../bloc/payment_methods/payment_methods_state.dart';
import '../../bloc/payment_methods/payment_methods_event.dart';
import 'matching_results_page.dart';

/// Guided Matching – criteria input form.
class MatchingCriteriaPage extends StatefulWidget {
  const MatchingCriteriaPage({super.key});

  @override
  State<MatchingCriteriaPage> createState() => _MatchingCriteriaPageState();
}

class _MatchingCriteriaPageState extends State<MatchingCriteriaPage> {
  final _formKey = GlobalKey<FormState>();
  String _tradeType = 'buy';
  String _crypto = 'BTC/USDT';
  String _amount = '';
  final Set<String> _selectedPaymentMethodIds = {};
  String _pricePref = 'best';
  String _traderPref = 'any';
  String _location = 'any';

  @override
  void initState() {
    super.initState();
    // Load payment methods list (if bloc exists)
    context.read<PaymentMethodsBloc>().add(const PaymentMethodsRequested());
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final bloc = context.read<GuidedMatchingBloc>();
      bloc.add(
          GuidedMatchingFieldUpdated(field: 'tradeType', value: _tradeType));
      bloc.add(
          GuidedMatchingFieldUpdated(field: 'cryptocurrency', value: _crypto));
      bloc.add(GuidedMatchingFieldUpdated(
          field: 'amount', value: double.parse(_amount)));
      bloc.add(GuidedMatchingFieldUpdated(
          field: 'paymentMethods', value: _selectedPaymentMethodIds.toList()));
      bloc.add(GuidedMatchingFieldUpdated(
          field: 'pricePreference', value: _pricePref));
      bloc.add(GuidedMatchingFieldUpdated(
          field: 'traderPreference', value: _traderPref));
      bloc.add(GuidedMatchingFieldUpdated(field: 'location', value: _location));
      bloc.add(const GuidedMatchingRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          context.colors.surface,
      appBar: AppBar(
        title: const Text('Smart Match'),
        backgroundColor:
            context.colors.surface,
      ),
      body: BlocListener<GuidedMatchingBloc, GuidedMatchingState>(
        listener: (context, state) {
          if (state is GuidedMatchingLoaded) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<GuidedMatchingBloc>(),
                  child: const MatchingResultsPage(),
                ),
              ),
            );
          } else if (state is GuidedMatchingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTradeTypeSelector(),
                const SizedBox(height: 16),
                _buildCryptoField(),
                const SizedBox(height: 16),
                _buildAmountField(),
                const SizedBox(height: 16),
                _buildPaymentMethods(),
                const SizedBox(height: 16),
                _buildPricePreference(),
                const SizedBox(height: 16),
                _buildTraderPreference(),
                const SizedBox(height: 16),
                _buildLocationField(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Find Matches'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTradeTypeSelector() {
    return Row(
      children: [
        const Text('Trade Type'),
        const Spacer(),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'buy', label: Text('Buy')),
            ButtonSegment(value: 'sell', label: Text('Sell')),
          ],
          selected: {_tradeType},
          onSelectionChanged: (set) {
            setState(() => _tradeType = set.first);
          },
        ),
      ],
    );
  }

  Widget _buildCryptoField() {
    return TextFormField(
      initialValue: _crypto,
      decoration: const InputDecoration(labelText: 'Cryptocurrency (pair)'),
      validator: (v) => v == null || v.isEmpty ? 'Enter pair' : null,
      onChanged: (v) => _crypto = v,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Amount'),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'Enter amount';
        }
        final parsed = double.tryParse(v);
        if (parsed == null || parsed <= 0) {
          return 'Invalid amount';
        }
        return null;
      },
      onChanged: (v) => _amount = v,
    );
  }

  Widget _buildPaymentMethods() {
    return BlocBuilder<PaymentMethodsBloc, PaymentMethodsState>(
      builder: (context, state) {
        if (state is PaymentMethodsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final methods = state is PaymentMethodsLoaded ? state.methods : [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Methods'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: methods.map((m) {
                final selected = _selectedPaymentMethodIds.contains(m.id);
                return FilterChip(
                  label: Text(m.name),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      if (selected) {
                        _selectedPaymentMethodIds.remove(m.id);
                      } else {
                        _selectedPaymentMethodIds.add(m.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPricePreference() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Price Preference'),
        Row(
          children: [
            Radio<String>(
              value: 'best',
              groupValue: _pricePref,
              onChanged: (v) => setState(() => _pricePref = v!),
            ),
            const Text('Best Price'),
            Radio<String>(
              value: 'fast',
              groupValue: _pricePref,
              onChanged: (v) => setState(() => _pricePref = v!),
            ),
            const Text('Fast Match'),
          ],
        ),
      ],
    );
  }

  Widget _buildTraderPreference() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Trader Preference'),
        Row(
          children: [
            Radio<String>(
              value: 'verified',
              groupValue: _traderPref,
              onChanged: (v) => setState(() => _traderPref = v!),
            ),
            const Text('Verified'),
            Radio<String>(
              value: 'any',
              groupValue: _traderPref,
              onChanged: (v) => setState(() => _traderPref = v!),
            ),
            const Text('Any'),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Country (optional)'),
      onChanged: (v) => _location = v,
    );
  }
}
