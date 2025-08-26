import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
	const EmptyState({super.key});

	@override
	Widget build(BuildContext context) {
		return Center(
			child: Text(
				'No notes yet...',
				textAlign: TextAlign.center,
				style: Theme.of(context).textTheme.titleMedium,
			),
		);
	}
}