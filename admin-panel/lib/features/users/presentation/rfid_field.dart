import "dart:async";

import "package:fast_immutable_collections/fast_immutable_collections.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:reactive_forms_annotations/reactive_forms_annotations.dart";
import "package:toastification/toastification.dart";

import "../../../database/models.dart";
import "../../../mqtt_client.dart";

Future<AccessZone?> showZoneSelectionDialog(
  BuildContext context,
  IList<AccessZone> zones,
) {
  return showDialog<AccessZone>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Wybierz strefę"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: zones.length,
            itemBuilder: (context, index) {
              final zone = zones[index];
              return ListTile(
                title: Text("Strefa ${zone.number}"),
                subtitle: Text(zone.location),
                onTap: () {
                  Navigator.of(context).pop(zone);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Anuluj"),
          ),
        ],
      );
    },
  );
}

Future<void> showLoadingDialog(
  BuildContext context,
  WidgetRef ref,
  int zoneId,
  FormControl<String>? rfidCardControl,
) {
  StreamSubscription<AccessMessage>? stream;
  final skipper = ref.read(mqttSkipListeningProvider.notifier);
  skipper.setZoneIdtoSkip(zoneId);
  stream = ref.watch(mqttClientProvider).value?.listen((event) async {
    if (event.zoneId == zoneId) {
      skipper.setZoneIdtoSkip(null);
      await stream?.cancel();
      rfidCardControl?.value = event.rfidCard;
      if (context.mounted) Navigator.of(context).pop();
      toastification.show(
        title: const Text("Karta zeskanowana"),
        description: const Text("Użytkownik ma dostęp do strefy"),
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 5),
      );
    }
  });

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: const SizedBox(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Czekam na skan karty RFID..."),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await stream?.cancel();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  );
}

class RfidField extends ConsumerWidget {
  const RfidField({
    super.key,
    required this.rfidCardControl,
    required this.zones,
  });

  final FormControl<String>? rfidCardControl;
  final IList<AccessZone> zones;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReactiveTextField<String>(
      readOnly: true,
      onTap: (_) {
        toastification.show(
          title: const Text("Kartę RFID można tylko zeskanować"),
          type: ToastificationType.warning,
          autoCloseDuration: const Duration(seconds: 2),
        );
      },
      formControl: rfidCardControl,
      canRequestFocus: false,
      decoration: InputDecoration(
        hintText: "Proszę zeskanować kartę",
        labelText: "Karta RFID",
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        alignLabelWithHint: false,
        fillColor: Colors.grey[200],
        filled: true,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: "Zeskanuj kartę RFID",
              child: IconButton(
                onPressed: () async {
                  final selectedZone =
                      await showZoneSelectionDialog(context, zones);
                  if (selectedZone != null && context.mounted) {
                    await showLoadingDialog(
                      context,
                      ref,
                      selectedZone.id,
                      rfidCardControl,
                    );
                  }
                },
                icon: const Icon(Icons.spatial_tracking_sharp),
              ),
            ),
            Tooltip(
              message: "Wyczyść pole RFID",
              child: IconButton(
                onPressed: () {
                  rfidCardControl?.value = "";
                },
                icon: const Icon(Icons.cancel_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
