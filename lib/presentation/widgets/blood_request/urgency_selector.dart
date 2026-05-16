import 'package:flutter/material.dart';

const bloodRequestUrgencyLevels = ['NORMAL', 'HIGH', 'CRITICAL'];

String urgencyLabel(String value) {
  switch (value) {
    case 'HIGH':
      return 'عاجل';
    case 'CRITICAL':
      return 'حرج';
    default:
      return 'عادي';
  }
}

class UrgencySelector extends StatelessWidget {
  const UrgencySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('درجة الإلحاح', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: bloodRequestUrgencyLevels
              .map(
                (level) => ButtonSegment<String>(
                  value: level,
                  label: Text(urgencyLabel(level)),
                ),
              )
              .toList(growable: false),
          selected: {value},
          onSelectionChanged: (selected) {
            if (selected.isNotEmpty) onChanged(selected.first);
          },
        ),
      ],
    );
  }
}
