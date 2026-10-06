import 'package:all_in_one/features/finance/data/payment.dart';
import 'package:all_in_one/features/finance/domain/payment_category.dart';
import 'package:all_in_one/features/finance/domain/subscription_brand.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_icons/simple_icons.dart';

Payment pay(String name) => Payment(
      id: name,
      name: name,
      amountMxn: 100,
      category: 'Streaming',
      dayOfMonth: 1,
    );

void main() {
  group('SubscriptionBrand.detect', () {
    test('reconoce marcas sin importar mayúsculas ni texto extra', () {
      expect(SubscriptionBrand.detect('Netflix')?.icon, SimpleIcons.netflix);
      expect(SubscriptionBrand.detect('spotify premium')?.icon, SimpleIcons.spotify);
      expect(SubscriptionBrand.detect('Mi cuenta de YouTube')?.icon, SimpleIcons.youtube);
    });

    test('un nombre no reconocido devuelve null', () {
      expect(SubscriptionBrand.detect('Renta del depa'), isNull);
      expect(SubscriptionBrand.detect('Gimnasio'), isNull);
    });

    test('el color oscuro (GitHub) se aclara para seguir siendo visible', () {
      final github = SubscriptionBrand.detect('GitHub Pro')!;
      // El logo original es casi negro; el getter le pone un piso de luminosidad.
      expect(github.color.computeLuminance(), greaterThan(0.05));
    });
  });

  group('Payment.display*', () {
    test('un pago con marca usa su icono y color, no el de la categoría', () {
      final netflix = pay('Netflix');
      expect(netflix.displayIcon, SimpleIcons.netflix);
      expect(netflix.displayColor, isNot(PaymentCategory.streaming.color));
    });

    test('un pago sin marca cae en el preset de la categoría', () {
      final renta = Payment(
        id: 'r',
        name: 'Renta depa',
        amountMxn: 8000,
        category: 'Renta',
        dayOfMonth: 1,
      );
      expect(renta.displayIcon, PaymentCategory.renta.icon);
      expect(renta.displayColor, PaymentCategory.renta.color);
    });

    test('un icono/color personalizado gana sobre la marca detectada', () {
      final custom = Payment(
        id: 'c',
        name: 'Netflix',
        amountMxn: 219,
        category: 'Streaming',
        dayOfMonth: 1,
        iconKey: 'star',
        colorValue: 0xFF123456,
      );
      // Aunque el nombre es "Netflix", manda lo que el usuario eligió.
      expect(custom.displayColor, const Color(0xFF123456));
      expect(custom.brand, isNotNull); // la marca se detecta, pero no se usa
    });
  });
}
