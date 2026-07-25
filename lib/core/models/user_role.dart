enum UserRole {
  client,
  livreur,
  admin;

  String get homeRoute {
    switch (this) {
      case UserRole.client:
        return '/client';
      case UserRole.livreur:
        return '/livreur';
      case UserRole.admin:
        return '/admin';
    }
  }
}
