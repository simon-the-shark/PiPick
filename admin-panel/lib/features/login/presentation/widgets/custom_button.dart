import "dart:async";

import "package:auto_route/auto_route.dart";
import "package:flutter/material.dart";

class CustomButton extends StatelessWidget {
  final String text;
  final List<PageRouteInfo<dynamic>> route;

  const CustomButton({
    super.key,
    required this.text,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        
        unawaited(context.router.replaceAll(route));
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
        ),
      ),
      child: Text(text),
    );
  }
}
