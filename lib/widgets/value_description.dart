import 'package:flutter/material.dart';

class ValueDescription extends StatelessWidget {
  const ValueDescription({
    super.key,
    required this.value,
    required this.description,
  });
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
        ),
        const Padding(padding: EdgeInsets.only(top: 10)),
        Text(description.toString()),
      ],
    );
  }
}
