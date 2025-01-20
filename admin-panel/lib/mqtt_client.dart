import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'database/provider.dart';
import 'database/models.dart';

Future<void> setupMqtt(WidgetRef ref) async {
  final client = MqttServerClient('localhost', 'flutter_client');
  client.port = 1883;
  client.logging(on: kDebugMode);
  client.keepAlivePeriod = 20;

  final connMessage = MqttConnectMessage()
      .withClientIdentifier('flutter_client')
      .keepAliveFor(20)
      .withWillTopic('pipick/lastwill')
      .withWillMessage('Client disconnected')
      .startClean()
      .withWillQos(MqttQos.atLeastOnce);

  client.connectionMessage = connMessage;

  try {
    print('Connecting with MQTT broker...');
    await client.connect();
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Connected with MQTT broker');
    } else {
      print('Connection failed: ${client.connectionStatus}');
      client.disconnect();
    }
  } catch (e) {
    print('Connection error: $e');
    client.disconnect();
  }

  const topic = 'pipick/logs';
  client.subscribe(topic, MqttQos.atMostOnce);

  client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) async {
    final recMessage = c[0].payload as MqttPublishMessage;
    final payload =
        MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

    print('Received message: $payload from topic: ${c[0].topic}');

    try {
        final Map<String, dynamic> jsonData = jsonDecode(payload);

        if (jsonData['msg'] != null) {
            // no way to log it in current model 
            print("message in payload: ${jsonData['msg']}");
            
        }
        else {
            final String date = jsonData['date'];
            final DateTime dateTime = DateTime.parse(date);

            final String rfidCard = jsonData['rfidCard'].toString();

            
            await saveLogToIsar(ref, rfidCard, dateTime);
        }


    } catch (e) {
      print('Error parsing JSON: $e');
    }

  });
}

Future<void> saveLogToIsar(WidgetRef ref, String rfidCard, DateTime dateTime) async {
  final isar = await ref.read(isarProvider.future);
  
  final logEntry = Logs()
    ..timestamp = dateTime
    ..successful = true
    ..rfidCard = rfidCard;

  await isar.writeTxn(() async {
    await isar.logs.put(logEntry);
  });

}
