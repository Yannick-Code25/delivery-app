class AppRoutes {
  AppRoutes._();

  static const welcome = '/';
  static const login = '/login';
  static const signup = '/signup';

  static const client = '/client';
  static const clientSearch = '/client/recherche';
  static const clientOrders = '/client/commandes';
  static const clientProfile = '/client/profil';

  static const livreur = '/livreur';
  static const admin = '/admin';

  static const authRoutes = {welcome, login, signup};
}
