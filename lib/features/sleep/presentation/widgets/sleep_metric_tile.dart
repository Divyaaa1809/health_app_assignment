import 'package:flutter/material.dart';

class SleepMetricTile extends StatelessWidget {
  final String title;
  final String value;
  final String description;

  const SleepMetricTile({
    super.key,
    required this.title,
    required this.value,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
