import 'package:flutter/material.dart';

import '../../../shared/widgets/role_home_placeholder.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleHomePlaceholder(
      title: 'Espace Client',
      icon: Icons.storefront_outlined,
    );
  }
}
