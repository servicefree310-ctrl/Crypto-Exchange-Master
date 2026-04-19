import 'package:flutter/material.dart';
import '../../widgets/create_offer_wizard/p2p_offer_creation_wizard.dart';

/// P2P Create Offer Page - Simple wrapper for the new wizard
class CreateOfferPage extends StatelessWidget {
  const CreateOfferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const P2POfferCreationWizard();
  }
}
