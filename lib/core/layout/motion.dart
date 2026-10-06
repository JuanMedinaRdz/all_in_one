import 'package:flutter/widgets.dart';

/// Si el sistema pidió **reducir movimiento** (accesibilidad). Cuando es `true`,
/// los widgets animados deben pintar su estado base quieto y no arrancar
/// controladores en bucle. Equivale al `@media (prefers-reduced-motion)` del web.
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeOf(context)?.disableAnimations ?? false;
