import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:reactive_forms_annotations/reactive_forms_annotations.dart";
import "package:toastification/toastification.dart";

import "../../../mqtt_client.dart";

class RfidField extends ConsumerWidget {
  const RfidField({
    super.key,
    required this.rfidCardControl,
  });
  final FormControl<String>? rfidCardControl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mqtt = ref.watch(mqttClientProvider);

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
                onPressed: () {
                  rfidCardControl?.value = "RANDOM-RFID-CARD-NUMBEr";
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
