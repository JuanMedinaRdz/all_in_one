import 'package:flutter/material.dart';

/// De dónde salió un evento del calendario.
enum CalendarEventKind { payment, note, debt, todo }

/// Algo que pasa un día: un cobro o una nota con fecha.
///
/// Es una vista, no un dato guardado: se arma en memoria a partir de los pagos
/// y las notas que ya tenemos en los streams. No existe una colección
/// `events` en Firestore ni hace falta mantenerla sincronizada.
class CalendarEvent {
  const CalendarEvent({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.kind,
    this.subtitle,
    this.amountMxn,
    this.sourceId,
    this.imageUrl,
  });

  final String id;
  final String title;

  /// Qué hay que hacer ese día ("Streaming · $239.00", "Por hacer").
  final String? subtitle;

  final IconData icon;
  final Color color;
  final CalendarEventKind kind;

  /// Foto de portada del pago, si tiene: se muestra en miniatura en vez del
  /// icono.
  final String? imageUrl;

  /// Solo en pagos: sirve para sumar el total del día.
  final double? amountMxn;

  /// Id del pago o la nota original, para poder abrirlo al tocarlo.
  final String? sourceId;

  bool get isPayment => kind == CalendarEventKind.payment;
}

/// Normaliza una fecha a medianoche.
///
/// Comparar días con `DateTime` completos falla siempre: dos instantes del
/// mismo día con distinta hora no son iguales. Todo el calendario compara
/// usando esto.
DateTime dayKey(DateTime date) => DateTime(date.year, date.month, date.day);
