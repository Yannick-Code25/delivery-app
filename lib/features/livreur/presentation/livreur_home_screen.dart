import 'package:flutter/material.dart';

import '../../../shared/widgets/role_home_placeholder.dart';

class LivreurHomeScreen extends StatelessWidget {
  const LivreurHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleHomePlaceholder(
      title: 'Espace Livreur',
      icon: Icons.delivery_dining_outlined,
    );
  }
}
