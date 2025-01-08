import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "../../database/models.dart";
import "freq_chart.dart";
import "logs_by_zone_repository.dart";

class DashboardPage extends HookConsumerWidget {
  const DashboardPage({
    super.key,
    required this.accessZone,
  });
  final AccessZone accessZone;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesFrequency = ref.watch(entriesRequencyProvider(accessZone.id));
    final failedEntriesFrequency =
        ref.watch(failedEntriesFrequencyProvider(accessZone.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: switch ((entriesFrequency, failedEntriesFrequency)) {
        (
          AsyncData(value: final allFrequency),
          AsyncData(value: final failedFrequency),
        ) =>
          _DasboardPageContent(
            accessZone,
            allFrequency,
            failedFrequency,
          ),
        (final AsyncError error, _) ||
        (_, final AsyncError error) =>
          Text("Error: $error"),
        (_, _) => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _DasboardPageContent extends StatelessWidget {
  const _DasboardPageContent(
    this.accessZone,
    this.entriesFrequency,
    this.failedEntriesFrequency,
  );

  final AccessZone accessZone;
  final Map<String, int> entriesFrequency;
  final Map<String, int> failedEntriesFrequency;

  @override
  Widget build(BuildContext context) {
    if (entriesFrequency.keys.isEmpty && failedEntriesFrequency.keys.isEmpty) {
      return const Center(child: Text("No Logs Available"));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          spacing: 30,
          children: [
            FrequenciesChart(
              header: "Częstotliwość Wejść - ${accessZone.location}",
              freqMap: entriesFrequency,
              label: "Wejść",
              color: Colors.blue,
            ),
            FrequenciesChart(
              header: "Nieudane Wejścia - ${accessZone.location}",
              freqMap: failedEntriesFrequency,
              label: "Nieudanych Wejść",
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}
