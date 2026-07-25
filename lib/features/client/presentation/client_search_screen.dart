import 'package:flutter/material.dart';

import '../../../shared/widgets/coming_soon.dart';

class ClientSearchScreen extends StatelessWidget {
  const ClientSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ComingSoon(
      title: 'Recherche',
      icon: Icons.search,
      sourceMockup: 'recherche_client',
    );
  }
}
