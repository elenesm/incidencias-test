import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final bool loading;
  final String label;
  final VoidCallback? onPressed;

  const LoadingButton({super.key, required this.loading, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label),
      ),
    );
  }
}
