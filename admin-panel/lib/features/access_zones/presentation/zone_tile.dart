import "package:flutter/material.dart";

import "../../../database/models.dart";

class ZoneTile extends StatelessWidget {
  final AccessZone zone;

  const ZoneTile({
    super.key,
    required this.zone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: Text("Strefa(${zone.number}): ${zone.location}"),
        subtitle: Text(
          "Liczba użytkowników z dostępem: ${zone.zoneAllowedUsers.length}",
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: "Logi strefy",
              child: IconButton(onPressed: () {}, icon: const Icon(Icons.list)),
            ),
            Tooltip(
              message: "Wykresy strefy",
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bar_chart),
              ),
            ),
            Tooltip(
              message: "Edytuj strefę",
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
            ),
            Tooltip(
              message: "Usuń strefę",
              child: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
