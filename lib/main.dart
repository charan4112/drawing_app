import 'package:flutter/material.dart';
import 'dart:ui';

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

enum Shape {
  line,
  circle,
  square,
  arc,
  smileEmoji,
  heartEmoji,
  starEmoji,
  sunEmoji,
  partyEmoji,
  winkEmoji
}

class _DrawingAppState extends State<DrawingApp> {
  List<Map<String, dynamic>> drawings = [];
  Shape selectedShape = Shape.line;
  bool showEmojiPanel = false;
  bool showShapePanel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Drawing App')),
      body: Row(
        children: [
          // **Drawing Area**
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  final localPosition =
                      renderBox.globalToLocal(details.globalPosition);

                  if (drawings.isEmpty || drawings.last["points"] == null) {
                    drawings.add({
                      "shape": selectedShape,
                      "points": [localPosition]
                    });
                  } else {
                    drawings.last["points"].add(localPosition);
                  }
                });
              },
              onPanEnd: (_) {
                setState(() {
                  drawings.add({"shape": selectedShape, "points": null});
                });
              },
              child: CustomPaint(
                painter: MyPainter(drawings),
                size: Size.infinite,
              ),
            ),
          ),

          // **Right Side Panel for Emojis & Shapes**
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHoverIcon(Icons.emoji_emotions, "Emojis", () {
                setState(() {
                  showEmojiPanel = !showEmojiPanel;
                  showShapePanel = false;
                });
              }),
              SizedBox(height: 20),
              _buildHoverIcon(Icons.category, "Shapes", () {
                setState(() {
                  showShapePanel = !showShapePanel;
                  showEmojiPanel = false;
                });
              }),
            ],
          ),

          // **Emoji Selection Panel**
          if (showEmojiPanel) _buildEmojiPanel(),

          // **Shape Selection Panel**
          if (showShapePanel) _buildShapePanel(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            drawings.clear();
          });
        },
        label: Text("Clear"),
        icon: Icon(Icons.clear),
      ),
    );
  }

  // **Hoverable Button for Icons**
  Widget _buildHoverIcon(IconData icon, String label, VoidCallback onTap) {
    return MouseRegion(
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() {}),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            Text(label, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  // **Emoji Selection Panel**
  Widget _buildEmojiPanel() {
    return Container(
      width: 80,
      color: Colors.white,
      child: Column(
        children: [
          _buildEmojiOption(Shape.smileEmoji, "😊"),
          _buildEmojiOption(Shape.heartEmoji, "❤️"),
          _buildEmojiOption(Shape.starEmoji, "⭐"),
          _buildEmojiOption(Shape.sunEmoji, "🌞"),
          _buildEmojiOption(Shape.partyEmoji, "🎉"),
          _buildEmojiOption(Shape.winkEmoji, "😉"),
        ],
      ),
    );
  }

  // **Shape Selection Panel**
  Widget _buildShapePanel() {
    return Container(
      width: 80,
      color: Colors.white,
      child: Column(
        children: [
          _buildShapeOption(Shape.circle, "🟡"),
          _buildShapeOption(Shape.square, "⬛"),
          _buildShapeOption(Shape.arc, "⤴️"),
        ],
      ),
    );
  }

  // **Emoji Option**
  Widget _buildEmojiOption(Shape shape, String emoji) {
    return ListTile(
      title: Text(emoji, style: TextStyle(fontSize: 30)),
      onTap: () {
        setState(() {
          selectedShape = shape;
          showEmojiPanel = false;
        });
      },
    );
  }

  // **Shape Option**
  Widget _buildShapeOption(Shape shape, String shapeIcon) {
    return ListTile(
      title: Text(shapeIcon, style: TextStyle(fontSize: 30)),
      onTap: () {
        setState(() {
          selectedShape = shape;
          showShapePanel = false;
        });
      },
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
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (var drawing in drawings) {
      var shape = drawing["shape"];
      var points = drawing["points"] as List<Offset>?;

      if (points == null || points.isEmpty) continue;

      switch (shape) {
        case Shape.line:
          for (int i = 0; i < points.length - 1; i++) {
            canvas.drawLine(points[i], points[i + 1], paint);
          }
          break;
        case Shape.circle:
          canvas.drawCircle(points[0], 30, paint);
          break;
        case Shape.square:
          canvas.drawRect(
              Rect.fromCenter(center: points[0], width: 50, height: 50), paint);
          break;
        case Shape.arc:
          var rect = Rect.fromCenter(center: points[0], width: 60, height: 60);
          canvas.drawArc(rect, 0, 3.14, false, paint);
          break;
        case Shape.smileEmoji:
          _drawSmileEmoji(canvas, points[0]);
          break;
        case Shape.heartEmoji:
          _drawHeartEmoji(canvas, points[0]);
          break;
        case Shape.starEmoji:
          _drawStarEmoji(canvas, points[0]);
          break;
      }
    }
  }

  void _drawSmileEmoji(Canvas canvas, Offset center) {
    Paint paint = Paint()..color = Colors.yellow;
    canvas.drawCircle(center, 50, paint);
  }

  void _drawHeartEmoji(Canvas canvas, Offset center) {
    Paint paint = Paint()..color = Colors.red;
    canvas.drawCircle(center, 40, paint);
  }

  void _drawStarEmoji(Canvas canvas, Offset center) {
    Paint paint = Paint()..color = Colors.amber;
    canvas.drawCircle(center, 35, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
