import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FancyPicker extends StatelessWidget {
  final String label;
  final int itemCount;
  final FixedExtentScrollController controller;
  final ValueChanged<int> onChanged;

  const FancyPicker({
    super.key,
    required this.label,
    required this.itemCount,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black )),
        SizedBox(
          height: 128,
          width: 80,
          child: CupertinoPicker(
            looping: true,
            itemExtent: 64,
            scrollController: controller,
            onSelectedItemChanged: onChanged,
            children: List<Widget>.generate(
              itemCount,
              (i) => Center(
                child: Text(
                  i.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 32,
                    fontFamily: 'RobotoMono',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}