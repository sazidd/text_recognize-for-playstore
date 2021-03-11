import 'package:flutter/material.dart';

class TextAreaWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClickedCopy;
  final VoidCallback onSpeak;

  const TextAreaWidget({
    @required this.text,
    @required this.onClickedCopy,
    @required this.onSpeak,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Container(
                    height: 280,
                    padding: EdgeInsets.all(8),
                    alignment: Alignment.center,
                    child: SelectableText(
                      text.isEmpty ? 'Scan an Image to get text' : text,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      color: Colors.black,
                      size: 15,
                    ),
                    color: Colors.grey[200],
                    onPressed: onClickedCopy,
                  ),
                  IconButton(
                    icon: Icon(Icons.volume_up),
                    onPressed: () => onSpeak(),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
}
