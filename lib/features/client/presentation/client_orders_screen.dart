import 'package:flutter/material.dart';

import '../../../shared/widgets/coming_soon.dart';

class ClientOrdersScreen extends StatelessWidget {
  const ClientOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      title: 'Mes commandes',
      icon: Icons.receipt_long_outlined,
      sourceMockup: 'mes_commandes_babali_style',
    );
  }
}
