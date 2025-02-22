import "package:auto_route/auto_route.dart";
import "package:fast_immutable_collections/fast_immutable_collections.dart";
import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "../../../database/models.dart";
import "../data/frequencies_repositories.dart";
import "bar_combined_chart.dart";
import "seeder_btn.dart";

@RoutePage()
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 32),
            child: SeederBtn(accessZone),
          ),
        ],
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
  final IMap<String, int> entriesFrequency;
  final IMap<String, int> failedEntriesFrequency;

  @override
  Widget build(BuildContext context) {
    if (entriesFrequency.keys.isEmpty && failedEntriesFrequency.keys.isEmpty) {
      return const Center(child: Text("No Logs Available"));
    }

    return Padding(
      padding: const EdgeInsets.all(84),
      child: BarCombinedChart(
        entriesFrequency: entriesFrequency,
        failedEntriesFrequency: failedEntriesFrequency,
      ),
    );
  }
}
