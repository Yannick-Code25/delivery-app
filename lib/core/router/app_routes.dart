class AppRoutes {
  AppRoutes._();

  /// Launch animation; decides for itself where to send the user next.
  static const splash = '/';
  static const welcome = '/bienvenue';
  static const login = '/login';
  static const signup = '/signup';

  // Client tabs (each is a branch of the bottom-nav shell).
  static const client = '/client';
  static const clientSearch = '/client/recherche';
  static const clientOrders = '/client/commandes';
  static const clientProfile = '/client/profil';

  // Client screens pushed above the shell.
  static const clientCart = '/client/panier';
  static const clientCheckout = '/client/paiement';
  static const clientAddresses = '/client/adresses';
  static const clientPaymentMethods = '/client/moyens-de-paiement';

  static String clientRestaurant(String restaurantId) => '$client/restaurant/$restaurantId';

  static String clientProduct(String restaurantId, String itemId) =>
      '${clientRestaurant(restaurantId)}/produit/$itemId';

  static String clientOrderTracking(String orderId) => '$client/commande/$orderId/suivi';

  static String clientOrderReview(String orderId) => '$client/commande/$orderId/noter';

  static const livreur = '/livreur';
  static const admin = '/admin';

  static const authRoutes = {welcome, login, signup};
}
