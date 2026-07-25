import 'package:flutter_riverpod/legacy.dart';

import '../models/user_role.dart';

/// Holds the current signed-in user's role, or null if signed out.
/// TODO: replace with a real auth/session controller backed by the API.
final currentRoleProvider = StateProvider<UserRole?>((ref) => null);
