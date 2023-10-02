import 'package:flutter/material.dart';

class Additionalnformation extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const Additionalnformation(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          label,
          style: const TextStyle(
              fontSize: 15, color: Color.fromARGB(134, 230, 224, 224)),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
          ),
        )
      ],
    );
  }
}
