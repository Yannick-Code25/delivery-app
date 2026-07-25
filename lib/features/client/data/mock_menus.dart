import 'package:flutter/material.dart';

import '../domain/menu_item.dart';

/// Placeholder menus. The "petit-bistro" menu reproduces
/// ref/.../d_tails_restaurant; the pizza item carries the size and topping
/// choices from ref/.../d_tails_personnalisation_produit.
/// TODO: replace with the real menu endpoint once the backend exists.
const _burrataPhoto =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuD7OfR5gW5cVxFWgC25Ir3zs7Z0BaVxInm0uVQPn0yUokGQzvZfl-QBocz7NHBCmbpBROrdYrO4Z9YAmrDhJ9fZ2jqotnXA8wlN5e1_Z4Au-95feIMCB6SpLrovMhkq8dQ6dYe9pZOSJIbQoebc87oWxeYPaa7JoYuQscZIgGDBWU1EZTMTbN_5SBqqPdad4JiwnhHFAgtBQLah4WMjQIBDmSLyCY0m5cfB1yveKcZCqulV4I5P3GEQfLDzz_i_2GIUbTOiyutXbjnb';
const _tartarePhoto =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAl__TTEhnP2CWBaTJ6bBAFY4uzoAXUXk48Gztg-Y9bSJgjChyjXTS7AQLXPQIYiT9B0JFKGnZFwKbNUepkNaQCCHGmp5vj_7pf8hh6F0nNLQ6jAMAyEv9BIGY1urT2y9QhTigEsOTfvE-cj-heXfgC07VvrdwvPwbdzeyBMpD7-dg5zXrJJOL7ccl5bgKVCugIrZIYpqvj_SJmEx0ZkZ6-MuqNTbrB3JYF0MK4QYza94bZSo_kcPKYY4-rxkfnAIBSnrROxYGAHHKW';
const _entrecotePhoto =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuApbdbeZPgtfXaW5-YNw58tW0Nbx6Yf6x_ZU_sgntbgZolIfk22s05BD59hl3qV1PBM880sSdVcNJ4k09RERG8x3IJXrS2206lM4lV3H-dzoKuRvq8hT1lj58vL-PzM-wfejIqoFzzIPPhJlNXzy9lCpi_7QRb8al-Gg9WguMQTgMTpCqCzzvTwvk8D3o1fwjmZ2uPf6X6TOQQQOiGBfrUDQ0-L6ab_BDRoUZIqofIL6zmCEI9Tq5BcwtkzUFy44hvSyww0gj8EiRWF';
const _risottoPhoto =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAX6wZ2hQYjT26hwIy__z_bTO_48uRjIS7wAF0Yz5AXEgXb4YmQa-tMAEpzHmy5ekbSL37wI5GfipEwoeTEKDCJyjRzdjrs0mt0AeH0rClo1_cDmC8f7F2B_pdL9FXIZ7IjK8zj3dEvrrAjCyJaPS8Lsp0LfdpSM08-vFcblAIPCPJozHdL-9RdW1TsQbCaAWzJDtSWhduRLJ2YGQ3B9iR_UAkua7PhhaDwekNE5tlkJp_g9FxwICYpjluKItC41W1iqinX-hdbdfRa';
const _pizzaPhoto =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAe0HTQbSSqNuKVhiQWrbKRH-hsBaxpe0wVLTcpMDOOigZG9l1cWL-5-KXI9KJvDVwe66CGpacqsFIoEI6nquqNWZHJ3wv0dH5U537eQOA6zsISAsMmGBWSl0yNwX-t1nOy5KBzWoJt7pdAvRMMbOx8H6IuOY0L6UUf2aAen_eg79jcOdoIkO76R6FhKP8EnQRqCrvnVIZOiRFV3EBMSfg26R1bSTNn-Su0v2RF_kLqsfEW96Gf1TmpyKq8PfI_cxIgf9fgeMkvDaQ9';
const _burgerPhotoRef =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuB9V62cmLPWzo5ua_vofEOlri9wP4_-P-3bujcdW2z1U6JXl7XhOd-pNEXJUFA_f1eIMK6HyM3qDrsSBiQng_PKb4bcRZBqCZFfxCIwNcmcZMZka1EzS0hw1QTlqPVJVnWWEwyCHGrehVz7QH2rWITEbkFEINx2yk8rQJQ1VTQvJPZF7LoojmX0OeDXkMsBz3lN-n2XYRapQ7UZIvpCTo5iD5C7prfUpznRZXwnPtnYXw1gpC0p8b3uehWPNQv_uUlyatv03BarcEYm';
const _moussePhoto =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAgQChswVbYgam9c5w_YN79LdJPAAAVzwZnxNIDWoy7hc-wjCS86E8a2xz8Gw2ji4kU5OwS0vjI8vlWF31JcirIhkUJvP21XAuFSADpGpptgboAtBkI2Kqqv1SGEkUyVBvw2Eys-4ZtG4ekjWN63mxLGGoFUNUzIuDw0D3vbvpWitIMDdBEp2BjHtPHpCRmVIWTRbcnol5QOWaMu9R2OgoiSMl97hteXpfceYzTdg-dY4K3FNrBwhCOVCb0QqSz-tWW5AY29Zqb_c8N';

const _bistroMenu = <MenuCategory>[
  MenuCategory(
    id: 'entrees',
    name: 'Entrées',
    items: [
      MenuItem(
        id: 'burrata',
        name: 'Burrata des Pouilles',
        description:
            'Burrata crémeuse, tomates cerises marinées au basilic et pesto de pistaches maison.',
        price: 4500,
        imageUrl: _burrataPhoto,
      ),
      MenuItem(
        id: 'tartare-saumon',
        name: 'Tartare de Saumon',
        description: 'Saumon frais, dés de mangue, gingembre et citronnelle.',
        price: 4000,
        imageUrl: _tartarePhoto,
      ),
    ],
  ),
  MenuCategory(
    id: 'plats',
    name: 'Plats principaux',
    items: [
      MenuItem(
        id: 'entrecote',
        name: 'Entrecôte Maturée',
        description:
            '300g de bœuf maturé 30 jours, frites maison et sauce au poivre noir du Kerala.',
        price: 8500,
        imageUrl: _entrecotePhoto,
        extras: [
          MenuItemExtra(id: 'sauce-extra', label: 'Sauce supplémentaire', price: 500),
          MenuItemExtra(id: 'frites-extra', label: 'Frites supplémentaires', price: 1000),
        ],
      ),
      MenuItem(
        id: 'risotto',
        name: 'Risotto aux Cèpes',
        description:
            'Riz Carnaroli, cèpes frais, copeaux de parmesan 24 mois et huile de truffe blanche.',
        price: 6000,
        imageUrl: _risottoPhoto,
      ),
    ],
  ),
  MenuCategory(
    id: 'desserts',
    name: 'Desserts',
    items: [
      MenuItem(
        id: 'mousse-chocolat',
        name: 'Mousse au Chocolat Noir',
        description: '70% cacao, fleur de sel de Guérande et éclats de noisettes torréfiées.',
        price: 2500,
        imageUrl: _moussePhoto,
      ),
    ],
  ),
  MenuCategory(
    id: 'boissons',
    name: 'Boissons',
    items: [
      MenuItem(
        id: 'jus-bissap',
        name: 'Jus de bissap maison',
        description: 'Infusion d\'hibiscus, menthe fraîche et gingembre, servie bien fraîche.',
        price: 1000,
      ),
      MenuItem(
        id: 'eau-minerale',
        name: 'Eau minérale 50cl',
        description: 'Plate ou gazeuse.',
        price: 500,
      ),
    ],
  ),
];

const _pizzaMenu = <MenuCategory>[
  MenuCategory(
    id: 'pizzas',
    name: 'Pizzas',
    items: [
      MenuItem(
        id: 'margherita',
        name: 'Pizza Margherita',
        description:
            "L'authentique saveur de l'Italie : base tomate San Marzano, mozzarella fior di "
            "latte, basilic frais et un filet d'huile d'olive extra vierge.",
        price: 4000,
        rating: 4.9,
        imageUrl: _pizzaPhoto,
        sizes: [
          MenuItemSize(
            id: 'm',
            label: 'Médium (30cm)',
            price: 4000,
            icon: Icons.local_pizza_outlined,
          ),
          MenuItemSize(
            id: 'l',
            label: 'Large (40cm)',
            price: 5000,
            icon: Icons.local_pizza_outlined,
            iconScale: 1.25,
          ),
        ],
        extras: [
          MenuItemExtra(id: 'double-fromage', label: 'Double Fromage', price: 700),
          MenuItemExtra(id: 'olives', label: 'Olives Noires', price: 500),
          MenuItemExtra(id: 'champignons', label: 'Champignons frais', price: 500),
        ],
      ),
      MenuItem(
        id: 'quatre-fromages',
        name: 'Pizza Quatre Fromages',
        description: 'Mozzarella, gorgonzola, parmesan et chèvre frais.',
        price: 5000,
      ),
    ],
  ),
  MenuCategory(
    id: 'pasta',
    name: 'Pâtes',
    items: [
      MenuItem(
        id: 'carbonara',
        name: 'Tagliatelles Carbonara',
        description: 'Guanciale, jaune d\'œuf, pecorino et poivre noir.',
        price: 4500,
      ),
    ],
  ),
];

const _burgerMenu = <MenuCategory>[
  MenuCategory(
    id: 'burgers',
    name: 'Burgers',
    items: [
      MenuItem(
        id: 'classic-lab',
        name: 'Classic Lab',
        description: 'Bœuf haché, cheddar affiné, salade croquante, bacon et sauce maison.',
        price: 4500,
        imageUrl: _burgerPhotoRef,
        extras: [
          MenuItemExtra(id: 'bacon-extra', label: 'Bacon supplémentaire', price: 700),
          MenuItemExtra(id: 'cheddar-extra', label: 'Double cheddar', price: 500),
        ],
      ),
      MenuItem(
        id: 'veggie-lab',
        name: 'Veggie Lab',
        description: 'Galette de pois chiches, avocat, tomate et sauce yaourt-menthe.',
        price: 4000,
      ),
    ],
  ),
  MenuCategory(
    id: 'accompagnements',
    name: 'Accompagnements',
    items: [
      MenuItem(
        id: 'frites-maison',
        name: 'Frites maison',
        description: 'Coupées à la main, sel de mer.',
        price: 1500,
      ),
    ],
  ),
];

const _sushiMenu = <MenuCategory>[
  MenuCategory(
    id: 'makis',
    name: 'Makis & Rolls',
    items: [
      MenuItem(
        id: 'california',
        name: 'California Roll (8 pièces)',
        description: 'Surimi, avocat, concombre et sésame.',
        price: 3500,
      ),
      MenuItem(
        id: 'saumon-avocat',
        name: 'Maki saumon-avocat (6 pièces)',
        description: 'Saumon frais et avocat mûr.',
        price: 3000,
      ),
    ],
  ),
  MenuCategory(
    id: 'poke',
    name: 'Poké bowls',
    items: [
      MenuItem(
        id: 'poke-saumon',
        name: 'Poké saumon',
        description: 'Riz vinaigré, saumon, edamame, mangue et sauce ponzu.',
        price: 5000,
      ),
    ],
  ),
];

const _menusByRestaurant = <String, List<MenuCategory>>{
  'petit-bistro': _bistroMenu,
  'pizzaria-milano': _pizzaMenu,
  'burger-lab': _burgerMenu,
  'sushi-master': _sushiMenu,
};

List<MenuCategory> menuForRestaurant(String restaurantId) =>
    _menusByRestaurant[restaurantId] ?? const [];

MenuItem? menuItemById(String restaurantId, String itemId) {
  for (final category in menuForRestaurant(restaurantId)) {
    for (final item in category.items) {
      if (item.id == itemId) return item;
    }
  }
  return null;
}
