import "dart:async";
import "dart:convert";

import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:mqtt_client/mqtt_client.dart";
import "package:mqtt_client/mqtt_server_client.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "database/models.dart";
import "database/provider.dart";
import "features/logs/data/logs_repository.dart";

part "mqtt_client.g.dart";

@Riverpod(keepAlive: true)
class MqttHost extends _$MqttHost {
  @override
  String? build() {
    return null;
  }

  void setIp(String ip) {
    state = ip;
  }
}

typedef AccessMessage = ({
  String rfidCard,
  int zoneId,
});

@Riverpod(keepAlive: true)
Future<Stream<AccessMessage>> mqttClient(Ref ref) async {
  final host = ref.watch(mqttHostProvider);
  if (host == null) {
    throw Exception("MQTT host is not set");
  }
  final client = MqttServerClient(host, "flutter_client");
  client.port = 1883;
  client.logging(on: kDebugMode);
  client.keepAlivePeriod = 20;

  final connMessage = MqttConnectMessage()
      .withClientIdentifier("flutter_client")
      // ignore: deprecated_member_use
      .keepAliveFor(20)
      .withWillTopic("pipick/lastwill")
      .withWillMessage("Client disconnected")
      .startClean()
      .withWillQos(MqttQos.atLeastOnce);

  client.connectionMessage = connMessage;

  try {
    debugPrint("Connecting with MQTT broker...");
    await client.connect();
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint("Connected with MQTT broker");
    } else {
      debugPrint("Connection failed: ${client.connectionStatus}");
      client.disconnect();
    }
  } on Exception catch (e) {
    debugPrint("Connection error: $e");
    client.disconnect();
  }

  const topic = "pipick/logs";
  client.subscribe(topic, MqttQos.atMostOnce);
  final streamController = StreamController<AccessMessage>();

  final listenerSubscription = client.updates!.listen((updates) async {
    final recMessage = updates[0].payload as MqttPublishMessage;
    final payload =
        MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);

    debugPrint("Received message: $payload from topic: ${updates[0].topic}");

    try {
      final Map<String, dynamic> jsonData = jsonDecode(payload);

      if (jsonData["msg"] != null) {
        // no way to log it in current model
        debugPrint("message in payload: ${jsonData['msg']}");
      } else {
        final String date = jsonData["date"];
        final DateTime dateTime = DateTime.parse(date);
        final int zoneId = jsonData["zoneId"];
        final String rfidCard = jsonData["rfidCard"].toString();

        final isar = await ref.read(isarProvider.future);
        final zone = await isar.accessZones.get(zoneId);
        final logEntry = Logs()
          ..timestamp = dateTime
          ..successful = true
          ..rfidCard = rfidCard;
        logEntry.zone.value = zone;

        await isar.writeTxn(() async {
          await isar.logs.put(logEntry);
          await logEntry.zone.save();
        });

        ref.invalidate(allLogsRepositoryProvider);
        ref.invalidate(logsByZoneRepositoryProvider);

        streamController.sink.add((rfidCard: rfidCard, zoneId: zoneId));
      }
    } on Exception catch (e) {
      debugPrint("Error parsing JSON: $e");
    }
  });

  ref.onDispose(() {
    listenerSubscription.cancel();
    client.disconnect();
    streamController.close();
  });

  return streamController.stream.asBroadcastStream();
}
