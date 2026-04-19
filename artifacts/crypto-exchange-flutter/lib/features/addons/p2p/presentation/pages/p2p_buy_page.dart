import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../injection/injection.dart';
import '../bloc/offers/offers_bloc.dart';
import '../bloc/trades/trade_execution_bloc.dart';
import '../bloc/payment_methods/payment_methods_bloc.dart';
import 'package:mobile/features/wallet/presentation/bloc/deposit_bloc.dart';
import 'package:mobile/features/wallet/presentation/bloc/currency_price_bloc.dart';
import '../widgets/buy_wizard/p2p_buy_wizard.dart';

/// P2P Buy Page - Guided wizard for buying cryptocurrency
/// Follows v5 frontend structure with step-by-step process:
/// 1. Select trade type (buy/sell)
/// 2. Select wallet type (FIAT/SPOT/ECO)
/// 3. Select cryptocurrency and amount
/// 4. Select payment methods
/// 5. Add preferences and filters
/// 6. Find matching offers
class P2PBuyPage extends StatefulWidget {
  const P2PBuyPage({
    super.key,
    this.initialTradeType,
  });

  final String? initialTradeType;

  @override
  State<P2PBuyPage> createState() => _P2PBuyPageState();
}

class _P2PBuyPageState extends State<P2PBuyPage> {
  String? _selectedTradeType;

  @override
  void initState() {
    super.initState();
    _selectedTradeType = widget.initialTradeType;
  }

  void _onTradeTypeChanged(String? tradeType) {
    setState(() {
      _selectedTradeType = tradeType;
    });
  }

  String _getAppBarTitle() {
    if (_selectedTradeType == null) {
      return 'Crypto Trading - Smart Match';
    }
    return _selectedTradeType == 'BUY'
        ? 'Buy Crypto - Smart Match'
        : 'Sell Crypto - Smart Match';
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<OffersBloc>()),
        BlocProvider(create: (context) => getIt<TradeExecutionBloc>()),
        BlocProvider(create: (context) => getIt<PaymentMethodsBloc>()),
        BlocProvider(create: (context) => getIt<DepositBloc>()),
        BlocProvider(create: (context) => getIt<CurrencyPriceBloc>()),
      ],
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          backgroundColor: context.colors.surface,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: context.textPrimary),
          ),
          title: Text(
            _getAppBarTitle(),
            style: context.h6.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: P2PBuyWizard(
          initialTradeType: widget.initialTradeType,
          onTradeTypeChanged: _onTradeTypeChanged,
        ),
      ),
    );
  }
}
