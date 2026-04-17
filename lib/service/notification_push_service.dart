import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class PushService {

  static int _idCounter = 0;

  static Future<void> initialize() async {

    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'info',
          channelName: 'Información',
          channelDescription: 'Reservas confirmadas y avisos generales',
          defaultColor: const Color(0xFF1F5DA0),
          ledColor: const Color(0xFF1F5DA0),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'importante',
          channelName: 'Importante',
          channelDescription: 'Cancelaciones y avisos importantes',
          defaultColor: Colors.orange,
          ledColor: Colors.orange,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
        NotificationChannel(
          channelKey: 'alerta',
          channelName: 'Alertas',
          channelDescription: 'Límites alcanzados y alertas críticas',
          defaultColor: Colors.red,
          ledColor: Colors.red,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          enableVibration: true,
        ),
      ],
    );

    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  static Future<void> notificarInfo(String titulo, String mensaje) async {
    final id = ++_idCounter;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'info',
        groupKey: 'info_$id',
        title: '✅ $titulo',
        body: mensaje,
        notificationLayout: NotificationLayout.BigText,
        color: const Color(0xFF1F5DA0),
        autoDismissible: true,
      ),
    );
  }

  static Future<void> notificarImportante(String titulo, String mensaje) async {
    final id = ++_idCounter;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'importante',
        groupKey: 'importante_$id',
        title: '⚠️ $titulo',
        body: mensaje,
        notificationLayout: NotificationLayout.BigText,
        color: Colors.orange,
        autoDismissible: true,
      ),
    );
  }

  static Future<void> notificarAlerta(String titulo, String mensaje) async {
    final id = ++_idCounter;
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'alerta',
        groupKey: 'alerta_$id',
        title: '🚨 $titulo',
        body: mensaje,
        notificationLayout: NotificationLayout.BigText,
        color: Colors.red,
        autoDismissible: true,
      ),
    );
  }
}