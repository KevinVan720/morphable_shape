import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morphable_shape/MorphableShapeBorder.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(body: MyHomePage()),
      //home: Center(child: Text("Hello")),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  DynamicPath path;
  Shape startShape;
  Shape endShape;
  MorphableShapeBorder startBorder;
  MorphableShapeBorder endBorder;
  int selectedNodeIndex;
  double nodeSize = 8;
  Size shapeSize = Size(400, 400);
  bool isEditingPath = false;

  AnimationController controller;
  Animation animation;

  static int gridCount=30;

  @override
  void initState() {
    super.initState();
    path = TriangleShape().generateDynamicPath(
            Rect.fromLTRB(0, 0, shapeSize.width, shapeSize.height));



    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    Animation curve =
    CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    animation = Tween(begin: 0.0, end: 1.0).animate(curve)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed)
          controller.reverse();
        else if (status == AnimationStatus.dismissed) controller.forward();
      });

    controller.forward();

  }

  @override
  Widget build(BuildContext context) {

    startShape = PathShape(path: path);
    endShape = TriangleShape();

    startBorder = MorphableShapeBorder(shape: startShape);
    endBorder = MorphableShapeBorder(shape: endShape);

    MorphableShapeBorderTween shapeBorderTween =
    MorphableShapeBorderTween(begin: startBorder, end: endBorder);

    List<Widget> stackedComponents = [
      Container(
        width: shapeSize.width + nodeSize * 2,
        height: shapeSize.height + nodeSize * 2,
      ),

      Positioned(
        left: nodeSize,
        top: nodeSize,
        child: Material(
          animationDuration: Duration.zero,
          shape: startBorder,
          clipBehavior: Clip.antiAlias,
          child: Container(
            color: Colors.amberAccent,
            width: shapeSize.width,
            height: shapeSize.height,
          ),
        ),
      ),
      Positioned(
        left: nodeSize,
        top: nodeSize,
        child: CustomPaint(
          painter: MyPainter(path.getPath(shapeSize)),
          child: Container(
            decoration:
            BoxDecoration(border: Border.all(color: Colors.blueAccent)),
            width: shapeSize.width,
            height: shapeSize.height,
          ),
        ),
      ),
    ];

    if (isEditingPath) {
      stackedComponents.addAll(buildPathEdittingWidgets(path));
    } else {
      stackedComponents.add(buildResizeHandles(-1, -1));
      stackedComponents.add(buildResizeHandles(-1, 1));
      stackedComponents.add(buildResizeHandles(1, -1));
      stackedComponents.add(buildResizeHandles(1, 1));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Center(
          child: Container(
            child: GestureDetector(
              onDoubleTap: () {
                setState(() {
                  isEditingPath = !isEditingPath;
                });
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: stackedComponents,
              ),
            ),
          ),
        ),
        AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget child) {
              double t = animation.value;
              return Center(
                child: Material(
                  animationDuration: Duration.zero,
                  shape: shapeBorderTween.lerp(t),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    color: Colors.amberAccent,
                    width: shapeSize.width,
                    height: shapeSize.height,
                  ),
                ),
              );
            })
      ],
    );
  }

  Widget addControlPointWidget(DynamicPath path,int index) {
    int nextIndex = (index + 1) % path.nodes.length;
    List<Offset> controlPoints = path.getControlPointsAt(index);
    Offset tempPoint;
    List<Offset> splittedControlPoints;

    if (controlPoints.length == 2) {
      tempPoint = (controlPoints[0] + controlPoints[1]) / 2;
    } else {
      //tempPoint = DynamicPath.cubicAt(0.5, controlPoints);
      splittedControlPoints = DynamicPath.splitCubicAt(0.5, controlPoints);
      tempPoint = splittedControlPoints[3];
    }
    return Positioned(
      left: tempPoint.dx,
      top: tempPoint.dy,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (splittedControlPoints != null) {
              path.nodes[index].nextControlPoints = splittedControlPoints[1];
              path.nodes[nextIndex].prevControlPoints =
                  splittedControlPoints[5];
              path.nodes.insert(
                  nextIndex,
                  DynamicNode(
                      position: splittedControlPoints[3],
                      prevControlPoints: splittedControlPoints[2],
                      nextControlPoints: splittedControlPoints[4]));
            } else {
              path.nodes.insert(index + 1, DynamicNode(position: tempPoint));
            }
            selectedNodeIndex = null;
          });
        },
        child: Container(
            width: 2 * nodeSize,
            height: 2 * nodeSize,
            decoration: ShapeDecoration(
                color: Colors.transparent,
                shape: CircleBorder(side: BorderSide(width: 2)))),
      ),
    );
  }

  List<Widget> buildPathEdittingWidgets(DynamicPath path) {
    List<Widget> nodeControls = [];
    if (selectedNodeIndex != null) {
      DynamicNode tempSelectedNode =
          path.getNodeWithControlPoints(selectedNodeIndex);
      int nextIndex = (selectedNodeIndex + 1) % path.nodes.length;
      int prevIndex = (selectedNodeIndex - 1) % path.nodes.length;
      nodeControls.add(Positioned(
          left: nodeSize,
          top: nodeSize,
          child: CustomPaint(
            painter: ControlPointPathPainter(
                startOffset: tempSelectedNode.prevControlPoints,
                middleOffset: tempSelectedNode.position,
                endOffset: tempSelectedNode.nextControlPoints),
            child: Container(
              width: shapeSize.width,
              height: shapeSize.height,
            ),
          )));
    }
    nodeControls.addAll(path.nodes
        .mapIndexed((e, index) => Positioned(
              left: e.position.dx,
              top: e.position.dy,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedNodeIndex != index) {
                      selectedNodeIndex = index;
                    } else {
                      selectedNodeIndex = null;
                    }
                  });
                },
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    if (selectedNodeIndex == index) {
                    path.updateNode(
                        index, Offset(details.delta.dx, details.delta.dy));
                    }
                  });
                },
                child: Container(
                  width: 2 * nodeSize,
                  height: 2 * nodeSize,
                  decoration: BoxDecoration(
                    color:
                        selectedNodeIndex == index ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ))
        .toList());
    if (selectedNodeIndex != null) {
      DynamicNode tempSelectedNode =
          path.getNodeWithControlPoints(selectedNodeIndex);
      int prevIndex = (selectedNodeIndex - 1) % path.nodes.length;

      nodeControls.add(addControlPointWidget(path, prevIndex));
      nodeControls.add(addControlPointWidget(path, selectedNodeIndex));

      nodeControls.add(Positioned(
        left: tempSelectedNode.prevControlPoints.dx,
        top: tempSelectedNode.prevControlPoints.dy,
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              path.updateNodeControl(
                  selectedNodeIndex,
                  true,
                  tempSelectedNode.prevControlPoints +
                      Offset(details.delta.dx, details.delta.dy));
              //path.nodes[index].position+=Offset(details.delta.dx, details.delta.dy);
            });
          },
          child: Container(
              width: 2 * nodeSize,
              height: 2 * nodeSize,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black))),
        ),
      ));
      nodeControls.add(Positioned(
        left: tempSelectedNode.nextControlPoints.dx,
        top: tempSelectedNode.nextControlPoints.dy,
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              path.updateNodeControl(
                  selectedNodeIndex,
                  false,
                  tempSelectedNode.nextControlPoints +
                      Offset(details.delta.dx, details.delta.dy));
              //path.nodes[index].position+=Offset(details.delta.dx, details.delta.dy);
            });
          },
          child: Container(
            width: 2 * nodeSize,
            height: 2 * nodeSize,
            decoration: BoxDecoration(
                color: Colors.white, border: Border.all(color: Colors.black)),
          ),
        ),
      ));
    }

    return nodeControls;
  }

  Widget buildResizeHandles(int alignX, int alignY) {
    double left, right, top, bottom;
    if (alignX == -1) left = 0;
    if (alignX == 1) right = 0;
    if (alignY == -1) top = 0;
    if (alignY == 1) bottom = 0;
    return Positioned(
        left: left,
        right: right,
        top: top,
        bottom: bottom,
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              shapeSize +=
                  Offset(details.delta.dx * alignX, details.delta.dy * alignY);
              path.resize(shapeSize);
            });
          },
          child: Container(
            width: 2 * nodeSize,
            height: 2 * nodeSize,
            decoration: ShapeDecoration(
              shape: CircleBorder(),
              color: Colors.green,
            ),
          ),
        ));
  }
}

class ControlPointPathPainter extends CustomPainter {
  var myPaint;
  Offset startOffset;
  Offset middleOffset;
  Offset endOffset;

  ControlPointPathPainter(
      {this.startOffset, this.middleOffset, this.endOffset}) {
    myPaint = Paint();
    myPaint.color = Colors.redAccent;
    myPaint.style = PaintingStyle.stroke;
    myPaint.strokeWidth = 4.0;
  }

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
      Path()
        ..moveTo(startOffset.dx, startOffset.dy)
        ..lineTo(middleOffset.dx, middleOffset.dy)
        ..lineTo(endOffset.dx, endOffset.dy),
      myPaint);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class MyPainter extends CustomPainter {
  Path path;
  var myPaint;

  MyPainter(this.path) {
    myPaint = Paint();
    myPaint.color = Color.fromRGBO(255, 0, 0, 1.0);
    myPaint.style = PaintingStyle.stroke;
    myPaint.strokeWidth = 5.0;
  }

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(path, myPaint);

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
