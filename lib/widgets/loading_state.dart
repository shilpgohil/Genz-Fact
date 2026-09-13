import 'package:flutter/material.dart';

import '../../core/theme/luma_tokens.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.label = 'Gathering your library'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: LumaTokens.space16),
          if (label.isNotEmpty)
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
