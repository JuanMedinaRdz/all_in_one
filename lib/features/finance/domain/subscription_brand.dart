import 'package:flutter/widgets.dart';
import 'package:simple_icons/simple_icons.dart';

/// Marca de suscripción reconocida (Netflix, Spotify...).
///
/// Los iconos vienen de `simple_icons`: son glifos **vectoriales** de fuente,
/// no imágenes PNG, así que respetan la restricción de "cero logos PNG" y se
/// pintan con el color oficial de cada marca.
///
/// Se detecta por el nombre del pago: escribes "Netflix" y su logo aparece
/// solo, sin que tengas que elegir nada.
class SubscriptionBrand {
  const SubscriptionBrand({
    required this.keywords,
    required this.icon,
    required Color color,
  }) : _color = color;

  /// Palabras que, si aparecen en el nombre del pago, activan esta marca.
  final List<String> keywords;
  final IconData icon;
  final Color _color;

  /// Color de marca, con un piso de luminosidad para que los logos casi negros
  /// (GitHub, Apple, Notion) sigan siendo visibles también en modo oscuro.
  Color get color {
    final hsl = HSLColor.fromColor(_color);
    if (hsl.lightness >= 0.35) return _color;
    return hsl.withLightness(0.5).toColor();
  }

  /// Catálogo de marcas comunes. El orden importa: gana la primera que coincida.
  static final _all = <SubscriptionBrand>[
    SubscriptionBrand(
      keywords: ['netflix'],
      icon: SimpleIcons.netflix,
      color: SimpleIconColors.netflix,
    ),
    SubscriptionBrand(
      keywords: ['spotify'],
      icon: SimpleIcons.spotify,
      color: SimpleIconColors.spotify,
    ),
    SubscriptionBrand(
      keywords: ['youtube', 'yt premium'],
      icon: SimpleIcons.youtube,
      color: SimpleIconColors.youtube,
    ),
    SubscriptionBrand(
      keywords: ['hbo', 'max'],
      icon: SimpleIcons.max,
      color: SimpleIconColors.max,
    ),
    SubscriptionBrand(
      keywords: ['apple tv', 'appletv'],
      icon: SimpleIcons.appletv,
      color: SimpleIconColors.appletv,
    ),
    SubscriptionBrand(
      keywords: ['apple music'],
      icon: SimpleIcons.applemusic,
      color: SimpleIconColors.applemusic,
    ),
    SubscriptionBrand(
      keywords: ['icloud'],
      icon: SimpleIcons.icloud,
      color: SimpleIconColors.icloud,
    ),
    SubscriptionBrand(
      keywords: ['playstation', 'ps plus', 'ps+'],
      icon: SimpleIcons.playstation,
      color: SimpleIconColors.playstation,
    ),
    SubscriptionBrand(
      keywords: ['twitch'],
      icon: SimpleIcons.twitch,
      color: SimpleIconColors.twitch,
    ),
    SubscriptionBrand(
      keywords: ['crunchyroll'],
      icon: SimpleIcons.crunchyroll,
      color: SimpleIconColors.crunchyroll,
    ),
    SubscriptionBrand(
      keywords: ['paramount'],
      icon: SimpleIcons.paramountplus,
      color: SimpleIconColors.paramountplus,
    ),
    SubscriptionBrand(
      keywords: ['notion'],
      icon: SimpleIcons.notion,
      color: SimpleIconColors.notion,
    ),
    SubscriptionBrand(
      keywords: ['dropbox'],
      icon: SimpleIcons.dropbox,
      color: SimpleIconColors.dropbox,
    ),
    SubscriptionBrand(
      keywords: ['google drive', 'google one', 'gdrive'],
      icon: SimpleIcons.googledrive,
      color: SimpleIconColors.googledrive,
    ),
    SubscriptionBrand(
      keywords: ['discord', 'nitro'],
      icon: SimpleIcons.discord,
      color: SimpleIconColors.discord,
    ),
    SubscriptionBrand(
      keywords: ['github'],
      icon: SimpleIcons.github,
      color: SimpleIconColors.github,
    ),
    SubscriptionBrand(
      keywords: ['figma'],
      icon: SimpleIcons.figma,
      color: SimpleIconColors.figma,
    ),
    SubscriptionBrand(
      keywords: ['steam'],
      icon: SimpleIcons.steam,
      color: SimpleIconColors.steam,
    ),
  ];

  /// Busca la marca que corresponde a [name]. `null` si no reconoce ninguna.
  static SubscriptionBrand? detect(String name) {
    final n = name.toLowerCase();
    for (final brand in _all) {
      if (brand.keywords.any(n.contains)) return brand;
    }
    return null;
  }
}
