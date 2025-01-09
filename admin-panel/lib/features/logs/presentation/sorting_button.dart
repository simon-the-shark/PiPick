import "package:flutter/material.dart";
import "package:toastification/toastification.dart";

class SortingButton extends StatelessWidget {
  const SortingButton({
    super.key,
    required this.isAscending,
  });

  final ValueNotifier<bool> isAscending;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isAscending.value ? Icons.arrow_upward : Icons.arrow_downward,
      ),
      tooltip: "Sort by Date",
      onPressed: () {
        toastification.show(
          title: const Text("Sort functionality not implemented"),
          autoCloseDuration: const Duration(seconds: 3),
        );
      },
    );
  }
}
