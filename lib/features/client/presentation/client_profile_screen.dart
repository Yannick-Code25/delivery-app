import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/session/session_providers.dart';
import '../../../shared/widgets/coming_soon.dart';

class ClientProfileScreen extends ConsumerWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ComingSoon(
      title: 'Profil',
      icon: Icons.person_outline,
      sourceMockup: 'profil_utilisateur_babali_style',
      actions: [
        OutlinedButton(
          onPressed: () => ref.read(currentRoleProvider.notifier).state = null,
          child: const Text('Se déconnecter'),
        ),
      ],
    );
  }
}
