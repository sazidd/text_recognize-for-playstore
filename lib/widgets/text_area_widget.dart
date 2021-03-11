import 'package:flutter/material.dart';

class TextAreaWidget extends StatelessWidget {
  final String text;
  final VoidCallback onCopy;
  final VoidCallback onSpeak;
  final double height;

  const TextAreaWidget({
    @required this.text,
    @required this.onCopy,
    @required this.onSpeak,
    @required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            child: SelectableText(
              text.isEmpty ? 'Scan an Image to get text' : text,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.volume_up),
              onPressed: () => onSpeak(),
            ),
            IconButton(
              icon: Icon(
                Icons.copy,
                color: Colors.black,
                size: 15,
              ),
              color: Colors.grey[200],
              onPressed: onCopy,
            ),
          ],
        ),
      ],
    );
  }
}

// Column(
//   children: [
//     IconButton(
//       icon: Icon(
//         Icons.copy,
//         color: Colors.black,
//         size: 15,
//       ),
//       color: Colors.grey[200],
//       onPressed: onClickedCopy,
//     ),
//     IconButton(
//       icon: Icon(Icons.volume_up),
//       onPressed: () => onSpeak(),
//     ),
//   ],
// ),
