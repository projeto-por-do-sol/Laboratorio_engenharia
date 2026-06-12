import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icone;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.outline,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 5,
            shadowColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            textStyle: Theme.of(context).textTheme.titleMedium,
          ),
          child: Stack(
            children: [
              if (icone != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Icon(icone, size: 26),
              ),

              Align(
                alignment: Alignment.center,
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  label.toUpperCase(),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.outline
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

      ),
    );
  }
}
