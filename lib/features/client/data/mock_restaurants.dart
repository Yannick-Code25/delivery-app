import '../domain/restaurant.dart';

/// Placeholder catalogue mirroring the cards in ref/.../accueil_babali_style and
/// the header of ref/.../d_tails_restaurant.
///
/// TODO: replace with the real catalogue endpoint once the backend exists.
/// The image URLs come from the mockups and may expire — every card falls back
/// to a themed placeholder when one fails to load.
const _burgerPhoto =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuB9V62cmLPWzo5ua_vofEOlri9wP4_-P-3bujcdW2z1U6JXl7XhOd-pNEXJUFA_f1eIMK6HyM3qDrsSBiQng_PKb4bcRZBqCZFfxCIwNcmcZMZka1EzS0hw1QTlqPVJVnWWEwyCHGrehVz7QH2rWITEbkFEINx2yk8rQJQ1VTQvJPZF7LoojmX0OeDXkMsBz3lN-n2XYRapQ7UZIvpCTo5iD5C7prfUpznRZXwnPtnYXw1gpC0p8b3uehWPNQv_uUlyatv03BarcEYm';
const _burgerLogo =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCaSDX5SAzmpAWscqELUS9hp8OCPZvUfrWhr0bDeQUvYSmwTKdMYysBFjykgCx0qRE7zUcZ05Z8dm1upTiW2iS2ZvFfgpxwqn6DdOxoNqjewT5WhiXdhfvtI2kt0lNNP_9h7LT-y0ELJS9aHTAzOGeQSkINRTx-3cpuuXzNEknLzC_hcOVuxY9v4zxxYxQlt0lTQ-OWjd0CemWQNbWPBQuHzn4gOAacyIg_jwsGDtusMeSVcoEmnqgezPwwffy8VwNzYMd7GfT8Xr5a';
const _sushiPhoto =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCFHz4Ogruxvzyl9HVoK6ajp7gq8SIP_odUxc6sMqApABF3-zpZGVBJCRFuMMSGkm7K77_uh4CKgYqEiMJJfFvLl_RJAVjfGifzdMiWYmLx1HgZ_487MMEJovD3PkTcLGPFTx_ICqoy3b8q4_qQT81TxivyFuAhxp4tuDp8Nou3ElkDWvPaTSkrwVA2hQEXr1pkpJGsVRfRPaF4expVynVgnTBWgjerQpyzt6cSqprx99dGokeP6W71eLADAyQnfyeTn_GIHvhwCUFQ';
const _sushiLogo =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAZBSi33olIYICpym2HKGbxhjoqSocAKBTqrJeCuELcg0r9kEX3jXZAIQDdOel1h0Xt99LDdrZ2TqshuJC2xggjh-Q_vStnuG9eKvOqTb2b4PX9OVvFFDDQXu_yE7fqnoKcUc4duilOx85Np1rGPVIVolPpZg-2sCb4Z-eiCAs-p94KdN-_vbz5s-W3McTMG-R_aMaCZ0rSk-ybz9NLzJYFRFUOr6otPyrQe7zS_Tp0CXskk1fgm3knc4hLejKsw1oXnEaMzOwLU6u0';
const _pizzaPhoto =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuAe0HTQbSSqNuKVhiQWrbKRH-hsBaxpe0wVLTcpMDOOigZG9l1cWL-5-KXI9KJvDVwe66CGpacqsFIoEI6nquqNWZHJ3wv0dH5U537eQOA6zsISAsMmGBWSl0yNwX-t1nOy5KBzWoJt7pdAvRMMbOx8H6IuOY0L6UUf2aAen_eg79jcOdoIkO76R6FhKP8EnQRqCrvnVIZOiRFV3EBMSfg26R1bSTNn-Su0v2RF_kLqsfEW96Gf1TmpyKq8PfI_cxIgf9fgeMkvDaQ9';
const _pizzaLogo =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuA1gSC-RAxilRCi0kb7j5uusiOrHDK9zWM5pxIyuHYWZvulpIu05lr80vltZd01Tks46a2XUmpI8L8qOtx6AJ2xwRfDg6ejDRwC8Aq79MK4SmdK-qLtNl-j7mMmbbF1dUl_EsmcfBzvY07q-kkx8Bf-J_eFlY__cj9UxzkeIcURznCVOL2fEUUSPdQe655HUQtSdz7f9GroQmUGIzdxUITn3dOIf9qjKIsRgihauZ_c7G6iz04AkgNbIoCK3C1nJnRqWFLIIRMViTeE';
const _bistroPhoto =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCpsdEXNiEYMSdDNpJ_VQdFwPPEJcQTQc7nPo4P7axVX30rV9ClTqoT-M-WWvLuZTrUpYWyeWuI_qvOjTkyrKe8Zg8TuWjKmw4p0nXMGeGCWHoxFDUxo8mKI473VwFtPgFnC3JM7JRMpu0iN-W-7q6qjIdPeS6XTEfMtaKcIiuAMB8T6vJLVn8iNwfLmmLdlA3KThWlbjFqKQcSm6G4tfOgupZ8JQBq2SXT5HATFvrMbZN_v7bt-TdpfCc0smxHUUOoArn6Xr4Qut9X';

/// Prices are in CFA francs at locally realistic levels, not conversions of the
/// euro amounts printed in the mockups.
const mockRestaurants = <Restaurant>[
  Restaurant(
    id: 'petit-bistro',
    name: 'Le Petit Bistro Gourmet',
    categories: ['Français', 'Moderne'],
    rating: 4.8,
    reviewCount: 500,
    deliveryMinMinutes: 25,
    deliveryMaxMinutes: 35,
    deliveryFee: 500,
    imageUrl: _bistroPhoto,
    logoUrl: _bistroPhoto,
  ),
  Restaurant(
    id: 'burger-lab',
    name: 'The Burger Lab',
    categories: ['Américain', 'Burgers', 'Grill'],
    rating: 4.8,
    reviewCount: 320,
    deliveryMinMinutes: 25,
    deliveryMaxMinutes: 35,
    deliveryFee: 500,
    imageUrl: _burgerPhoto,
    logoUrl: _burgerLogo,
  ),
  Restaurant(
    id: 'sushi-master',
    name: 'Sushi Master',
    categories: ['Japonais', 'Sushi', 'Poké'],
    rating: 4.5,
    reviewCount: 210,
    deliveryMinMinutes: 15,
    deliveryMaxMinutes: 25,
    deliveryFee: 0,
    imageUrl: _sushiPhoto,
    logoUrl: _sushiLogo,
  ),
  Restaurant(
    id: 'pizzaria-milano',
    name: 'Pizzaria Milano',
    categories: ['Italien', 'Pizza', 'Pasta'],
    rating: 4.9,
    reviewCount: 480,
    deliveryMinMinutes: 30,
    deliveryMaxMinutes: 40,
    deliveryFee: 1000,
    imageUrl: _pizzaPhoto,
    logoUrl: _pizzaLogo,
  ),
];

Restaurant? restaurantById(String id) {
  for (final restaurant in mockRestaurants) {
    if (restaurant.id == id) return restaurant;
  }
  return null;
}
