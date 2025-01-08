import "package:flutter/material.dart";

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
        // Functionality not implemented
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sort functionality not implemented"),
          ),
        );
      },
    );
  }
}
