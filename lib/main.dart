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

enum Shape { line, circle, square, arc }

class _DrawingAppState extends State<DrawingApp> {
  List<Map<String, dynamic>> drawings = [];
  Shape selectedShape = Shape.line;

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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                drawings.clear();
              });
            },
            label: Text("Clear"),
            icon: Icon(Icons.clear),
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () {
              _showShapeSelectionDialog(context);
            },
            label: Text("Select Shape"),
            icon: Icon(Icons.category),
          ),
        ],
      ),
    );
  }

  void _showShapeSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Choose Shape"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShapeOption(Shape.line, "Line"),
              _buildShapeOption(Shape.circle, "Circle"),
              _buildShapeOption(Shape.square, "Square"),
              _buildShapeOption(Shape.arc, "Arc"),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShapeOption(Shape shape, String name) {
    return ListTile(
      title: Text(name),
      leading: Radio(
        value: shape,
        groupValue: selectedShape,
        onChanged: (Shape? value) {
          setState(() {
            selectedShape = value!;
          });
          Navigator.pop(context);
        },
      ),
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
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
