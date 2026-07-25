import 'package:flutter/material.dart';

import '../../../shared/widgets/role_home_placeholder.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RoleHomePlaceholder(
      title: 'Espace Admin',
      icon: Icons.admin_panel_settings_outlined,
    );
  }
}
