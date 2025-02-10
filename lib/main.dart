import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drawing App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DrawingApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DrawingApp extends StatefulWidget {
  @override
  _DrawingAppState createState() => _DrawingAppState();
}

enum Shape { freehand, circle, square, arc, emoji }

enum EmojiType { smile, party, heart }

class _DrawingAppState extends State<DrawingApp> {
  List<Map<String, dynamic>> drawings = [];
  Shape selectedShape = Shape.freehand;
  EmojiType? selectedEmoji;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Drawing App')),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            final localPosition =
                renderBox.globalToLocal(details.globalPosition);

            if (selectedShape == Shape.freehand) {
              if (drawings.isEmpty || drawings.last["points"] == null) {
                drawings.add({
                  "shape": selectedShape,
                  "points": [localPosition]
                });
              } else {
                drawings.last["points"].add(localPosition);
              }
            } else if (selectedShape == Shape.emoji && selectedEmoji != null) {
              drawings.add({
                "shape": selectedShape,
                "position": localPosition,
                "emoji": selectedEmoji
              });
            } else {
              drawings.add({"shape": selectedShape, "position": localPosition});
            }
          });
        },
        child: CustomPaint(
          painter: MyPainter(drawings),
          size: Size.infinite,
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "clear",
            backgroundColor: Colors.red,
            onPressed: () {
              setState(() {
                drawings.clear();
              });
            },
            child: Icon(Icons.clear),
          ),
          SizedBox(height: 15),
          FloatingActionButton(
            heroTag: "emoji",
            backgroundColor: Colors.purple,
            onPressed: () {
              _showEmojiSelection();
            },
            child: Icon(Icons.emoji_emotions),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildShapeButton("✏ Freehand", Shape.freehand),
            _buildShapeButton("⭕ Circle", Shape.circle),
            _buildShapeButton("⬛ Square", Shape.square),
            _buildShapeButton("🔄 Arc", Shape.arc),
            _buildShapeButton("😀 Emoji", Shape.emoji),
          ],
        ),
      ),
    );
  }

  Widget _buildShapeButton(String text, Shape shape) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedShape = shape;
        });
      },
      child: Text(text),
    );
  }

  void _showEmojiSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 120,
          child: Column(
            children: [
              Text("Select an Emoji",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _emojiButton("😊", EmojiType.smile),
                  _emojiButton("🥳", EmojiType.party),
                  _emojiButton("❤️", EmojiType.heart),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emojiButton(String emoji, EmojiType emojiType) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEmoji = emojiType;
          selectedShape = Shape.emoji;
        });
        Navigator.pop(context);
      },
      child: Text(emoji, style: TextStyle(fontSize: 40)),
    );
  }
}

class MyPainter extends CustomPainter {
  final List<Map<String, dynamic>> drawings;
  MyPainter(this.drawings);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 5.0;

    for (var drawing in drawings) {
      var shape = drawing["shape"];
      var points = drawing["points"] as List<Offset>?;
      var position = drawing["position"] as Offset?;
      var emoji = drawing["emoji"] as EmojiType?;

      switch (shape) {
        case Shape.freehand:
          if (points != null) {
            for (int i = 0; i < points.length - 1; i++) {
              canvas.drawLine(points[i], points[i + 1], paint);
            }
          }
          break;
        case Shape.circle:
          if (position != null) {
            canvas.drawCircle(position, 30, paint);
          }
          break;
        case Shape.square:
          if (position != null) {
            canvas.drawRect(
                Rect.fromCenter(center: position, width: 50, height: 50),
                paint);
          }
          break;
        case Shape.arc:
          if (position != null) {
            var rect = Rect.fromCenter(center: position, width: 60, height: 60);
            canvas.drawArc(rect, 0, 3.14, false, paint);
          }
          break;
        case Shape.emoji:
          if (position != null && emoji != null) {
            String emojiText = "😀";
            if (emoji == EmojiType.smile) emojiText = "😊";
            if (emoji == EmojiType.party) emojiText = "🥳";
            if (emoji == EmojiType.heart) emojiText = "❤️";
            TextPainter textPainter = TextPainter(
              text: TextSpan(text: emojiText, style: TextStyle(fontSize: 40)),
              textDirection: TextDirection.ltr,
            );
            textPainter.layout();
            textPainter.paint(canvas, position);
          }
          break;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
