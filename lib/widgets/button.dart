import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/utils.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.function,
    required this.text,
    required this.width,
  });
  final Function function;
  final String text;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: mobileSearchColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onTap: () {
            function();
          },
          child: Ink(
            width: width,
            height: MediaQuery.of(context).size.height * 0.045,
            child: Center(
              child: Text(
                text,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
