import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Theme.of(context).colorScheme.secondary,
      thickness: 2,
      // indent: 20,
      // endIndent: 20,
      height: 10,
    );
  }
}
