import 'package:weeklet/core/constants/category_icons.dart';
import 'package:weeklet/l10n/app_localizations.dart';

/// Maps a stable [CategoryIcon.name] to its localized display label.
abstract final class CategoryIconLabels {
  /// Returns the localized label for [icon], falling back to the English
  /// [CategoryIcon.label] for an unknown icon name.
  static String of(AppLocalizations l10n, CategoryIcon icon) =>
      switch (icon.name) {
        'home' => l10n.categoryIconHome,
        'wifi' => l10n.categoryIconWifi,
        'shopping_cart' => l10n.categoryIconShoppingCart,
        'directions_car' => l10n.categoryIconDirectionsCar,
        'account_balance_wallet' => l10n.categoryIconAccountBalanceWallet,
        'trending_up' => l10n.categoryIconTrendingUp,
        'restaurant' => l10n.categoryIconRestaurant,
        'local_cafe' => l10n.categoryIconLocalCafe,
        'movie' => l10n.categoryIconMovie,
        'sports_esports' => l10n.categoryIconSportsEsports,
        'fitness_center' => l10n.categoryIconFitnessCenter,
        'flight_takeoff' => l10n.categoryIconFlightTakeoff,
        'favorite' => l10n.categoryIconFavorite,
        'school' => l10n.categoryIconSchool,
        'work' => l10n.categoryIconWork,
        'directions_bus' => l10n.categoryIconDirectionsBus,
        'local_gas_station' => l10n.categoryIconLocalGasStation,
        'phone_iphone' => l10n.categoryIconPhoneIphone,
        'checkroom' => l10n.categoryIconCheckroom,
        'chair' => l10n.categoryIconChair,
        'pets' => l10n.categoryIconPets,
        'shield' => l10n.categoryIconShield,
        'medication' => l10n.categoryIconMedication,
        'menu_book' => l10n.categoryIconMenuBook,
        'music_note' => l10n.categoryIconMusicNote,
        'card_giftcard' => l10n.categoryIconCardGiftcard,
        'savings' => l10n.categoryIconSavings,
        'lightbulb' => l10n.categoryIconLightbulb,
        'build' => l10n.categoryIconBuild,
        'park' => l10n.categoryIconPark,
        'child_friendly' => l10n.categoryIconChildFriendly,
        'family_restroom' => l10n.categoryIconFamilyRestroom,
        'more_horiz' => l10n.categoryIconMoreHoriz,
        _ => icon.label,
      };
}
