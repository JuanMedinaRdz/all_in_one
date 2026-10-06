import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Un recordatorio a programar: qué avisar y cuándo.
class Reminder {
  const Reminder({
    required this.id,
    required this.title,
    required this.body,
    required this.when,
  });

  /// Id estable y único dentro del lote (se usa como id de la notificación).
  final int id;
  final String title;
  final String body;
  final DateTime when;
}

/// Programa notificaciones locales de recordatorio (pagos, deudas y notas con
/// fecha). Todo es **local en el dispositivo**: no hay servidor ni push, así
/// que no cuesta nada y funciona sin conexión.
class NotificationService {
  NotificationService();

  final _plugin = FlutterLocalNotificationsPlugin();
  var _ready = false;

  static const _channel = AndroidNotificationChannel(
    'reminders',
    'Recordatorios',
    description: 'Avisos de pagos, deudas y notas con fecha.',
    importance: Importance.high,
  );

  Future<void> init() async {
    if (_ready) return;
    try {
      // Zona horaria del dispositivo, para que "9 de la mañana" sea la de aquí.
      tzdata.initializeTimeZones();
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // En Windows los avisos son "toasts" del sistema. El GUID identifica
          // el callback de activación; el AUMID, la app. (En escritorio los
          // recordatorios son un extra: en el celular es donde de verdad sirven.)
          windows: WindowsInitializationSettings(
            appName: 'Todo en uno',
            appUserModelId: 'TodoEnUno.App',
            guid: 'b7a4c1e2-9d3f-4a6b-8c2e-1f0d5e7a9c34',
          ),
        ),
      );

      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(_channel);
      // Android 13+: pide el permiso de notificaciones. Si lo niega, no pasa
      // nada malo; simplemente no llegan avisos.
      await android?.requestNotificationsPermission();

      _ready = true;
    } catch (e, st) {
      debugPrint('No pude preparar las notificaciones: $e\n$st');
    }
  }

  /// Reemplaza todo lo programado por [reminders]. Se llama cada vez que los
  /// datos cambian: cancela lo viejo y reprograma lo vigente, así nunca quedan
  /// avisos de cosas ya borradas.
  Future<void> reschedule(List<Reminder> reminders) async {
    if (!_ready) return;
    try {
      await _plugin.cancelAll();
      final now = DateTime.now();
      for (final r in reminders) {
        // Solo futuro: `zonedSchedule` no puede programar en el pasado.
        if (!r.when.isAfter(now)) continue;
        await _plugin.zonedSchedule(
          id: r.id,
          title: r.title,
          body: r.body,
          scheduledDate: tz.TZDateTime.from(r.when, tz.local),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'reminders',
              'Recordatorios',
              channelDescription: 'Avisos de pagos, deudas y notas con fecha.',
              importance: Importance.high,
              priority: Priority.high,
            ),
            windows: WindowsNotificationDetails(),
          ),
          // Inexacto: evita pedir el permiso de "alarmas exactas" (Android 12+).
          // Un recordatorio no necesita precisión al segundo.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('No pude reprogramar recordatorios: $e');
    }
  }
}
