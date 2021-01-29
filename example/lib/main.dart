import 'dart:math';
import 'dart:convert';

import 'package:example/morph_shape_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:morphable_shape/borderShapes/bubble.dart';
import 'package:morphable_shape/borderShapes/circle.dart';
import 'package:morphable_shape/borderShapes/cutcorner.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:morphable_shape/morphable_shape_border.dart';

import 'value_pickers.dart';

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

      home: MyHomePage(),
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
  Shape currentShape;

  int selectedNodeIndex;
  double nodeSize = 8;
  Size shapeSize = Size(400, 400);
  bool isEditingPath = false;

  static int gridCount = 30;

  Axis direction;

  @override
  void initState() {
    super.initState();
    //currentShape = ArcShape();
    currentShape = PathShape(
        path: CutCornerShape().generateDynamicPath(
            Rect.fromLTRB(0, 0, shapeSize.width, shapeSize.height)));
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    if (screenSize.width > screenSize.height) {
      direction = Axis.horizontal;
    } else {
      direction = Axis.vertical;
    }

    MorphableShapeBorder startBorder;

    startBorder = MorphableShapeBorder(
        shape: currentShape, borderColor: Colors.redAccent, borderWidth: 1);

    List<Widget> stackedComponents = [
      Container(
        width: shapeSize.width + nodeSize * 2,
        height: shapeSize.height + nodeSize * 2,
      ),
      Positioned(
        left: nodeSize,
        top: nodeSize,
        child: Material(
          shape: startBorder,
          clipBehavior: Clip.antiAlias,
          animationDuration: Duration.zero,
          elevation: 10,
          child: Container(
            width: shapeSize.width,
            height: shapeSize.height,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
        ),
      ),
      Positioned(
        left: nodeSize,
        top: nodeSize,
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.blueAccent)),
          width: shapeSize.width,
          height: shapeSize.height,
        ),
      ),
    ];

    if (isEditingPath) {
      stackedComponents.addAll(buildEditingShapeControlWidgets());
    } else {
      stackedComponents.add(buildResizeHandles(-1, -1));
      stackedComponents.add(buildResizeHandles(-1, 1));
      stackedComponents.add(buildResizeHandles(1, -1));
      stackedComponents.add(buildResizeHandles(1, 1));
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          titleSpacing: 0.0,
          title: Text("Edit Shape"),
          centerTitle: true,
          elevation: 0,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.remove_red_eye),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MorphShapePage(
                                shape: currentShape,
                              )));
                })
            //_buildViewTreeButton(),
          ],
        ),
        body: Container(
          color: Colors.black54,
          child: Flex(
            direction: direction,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Center(
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
              ),
              isEditingPath
                  ? Container(
                      width: direction == Axis.horizontal ? 340 : screenSize,
                      decoration: BoxDecoration(color: Colors.grey, boxShadow: [
                        BoxShadow(
                            offset: Offset(-2, 2),
                            color: Colors.black54,
                            blurRadius: 5,
                            spreadRadius: 1)
                      ]),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        child: ListView(
                          children: buildEditingShapeDirectWidgets(),
                        ),
                      ),
                    )
                  : Container(
                      width: 0,
                    )
            ],
          ),
        ));
  }

  List<Widget> buildEditingShapeControlWidgets() {
    List<Widget> stackedComponents = [];
    if (currentShape is ArcShape) {
      stackedComponents.addAll(buildArcEditingWidgets(currentShape));
    }
    if (currentShape is BubbleShape) {
      stackedComponents.addAll(buildBubbleEditingWidgets(currentShape));
    }
    if (currentShape is CircleShape) {
      stackedComponents.addAll(buildCircleEditingWidgets(currentShape));
    }
    if (currentShape is CutCornerShape) {
      stackedComponents.addAll(buildCutCornerEditingWidgets(currentShape));
    }
    if (currentShape is DiagonalShape) {
      stackedComponents.addAll(buildDiagonalEditingWidgets(currentShape));
    }

    if (currentShape is PathShape) {
      stackedComponents.addAll(buildPathEditingWidgets(currentShape));
    }
    if (currentShape is PolygonShape) {
      stackedComponents.addAll(buildPolygonEditingWidgets(currentShape));
    }

    if (currentShape is RoundRectShape) {
      stackedComponents.addAll(buildRoundRectEditingWidgets(currentShape));
    }

    if (currentShape is StarShape) {
      stackedComponents.addAll(buildStarEditingWidgets(currentShape));
    }
    if (currentShape is TriangleShape) {
      stackedComponents.addAll(buildTriangleEditingWidgets(currentShape));
    }

    return stackedComponents;
  }

  List<Widget> buildEditingShapeDirectWidgets() {
    List<Widget> stackedComponents = [];

    if (currentShape is PathShape) {
      stackedComponents.addAll(buildPathEditingPanelWidget(currentShape));
    }

    if (currentShape is ArcShape) {
      stackedComponents.addAll(buildArcEditingPanelWidget(currentShape));
    }

    if (currentShape is BubbleShape) {
      stackedComponents.addAll(buildBubbleEditingPanelWidget(currentShape));
    }

    if (currentShape is CircleShape) {
      stackedComponents.addAll(buildCircleEditingPanelWidget(currentShape));
    }

    if (currentShape is CutCornerShape) {
      stackedComponents.addAll(buildCutCornerEditingPanelWidget(currentShape));
    }

    return stackedComponents;
  }

  Widget addControlPointWidget(PathShape shape, int index) {
    DynamicPath path = shape.path;
    int nextIndex = (index + 1) % path.nodes.length;
    List<Offset> controlPoints = path.getCubicControlPointsAt(index);
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
              path.nodes[index].next = splittedControlPoints[1];
              path.nodes[nextIndex].prev = splittedControlPoints[5];
              path.nodes.insert(
                  nextIndex,
                  DynamicNode(
                      position: splittedControlPoints[3],
                      prev: splittedControlPoints[2],
                      next: splittedControlPoints[4]));
            } else {
              path.nodes.insert(index + 1, DynamicNode(position: tempPoint));
            }
            currentShape = shape.copyWith(path: path);
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

  List<Widget> buildPathEditingWidgets(PathShape shape) {
    DynamicPath path = shape.path;
    path.resize(shapeSize);
    List<Widget> nodeControls = [];
    if (selectedNodeIndex != null) {
      DynamicNode tempSelectedNode =
          path.getNodeWithControlPoints(selectedNodeIndex);
      nodeControls.add(Positioned(
          left: nodeSize,
          top: nodeSize,
          child: CustomPaint(
            painter: ControlPointPathPainter(
                startOffset: tempSelectedNode.prev,
                middleOffset: tempSelectedNode.position,
                endOffset: tempSelectedNode.next),
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
                onPanStart: (DragStartDetails details) {
                  setState(() {
                    if (selectedNodeIndex != index) {
                      selectedNodeIndex = index;
                    }
                  });
                },
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    if (selectedNodeIndex == index) {
                      shape.path.moveNodeBy(
                          index, Offset(details.delta.dx, details.delta.dy));
                      currentShape = shape.copyWith(path: path);
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

      nodeControls.add(addControlPointWidget(shape, prevIndex));
      nodeControls.add(addControlPointWidget(shape, selectedNodeIndex));

      nodeControls.add(Positioned(
        left: tempSelectedNode.prev.dx,
        top: tempSelectedNode.prev.dy,
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              path.moveNodeControlTo(
                  selectedNodeIndex,
                  true,
                  tempSelectedNode.prev +
                      Offset(details.delta.dx, details.delta.dy));
              currentShape = shape.copyWith(path: path);
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
        left: tempSelectedNode.next.dx,
        top: tempSelectedNode.next.dy,
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              path.moveNodeControlTo(
                  selectedNodeIndex,
                  false,
                  tempSelectedNode.next +
                      Offset(details.delta.dx, details.delta.dy));
              currentShape = shape.copyWith(path: path);
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

  Widget dynamicShapeEditingDragWidget(
      {Offset position, Function onDragUpdate}) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        dragStartBehavior: DragStartBehavior.start,
        onPanUpdate: onDragUpdate,
        onPanStart: (DragStartDetails details) {
          setState(() {});
        },
        child: Container(
          width: 2 * nodeSize,
          height: 2 * nodeSize,
          decoration: BoxDecoration(
              color: Colors.amber, border: Border.all(color: Colors.black)),
        ),
      ),
    );
  }

  Length updateLength(Length length, double value,
      {double constraintSize,
      double minimumSize = 0.1,
      double maximumSize = double.infinity,
      Offset offset,
      double Function(Offset) offsetToDelta}) {
    double newValue = value + 1.0 * offsetToDelta(offset);
    return length.copyWith(
        value: Length.newValue(
            newValue.clamp(minimumSize, maximumSize), length.unit,
            constraintSize: constraintSize));
  }

  List<Widget> buildArcEditingWidgets(ArcShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    double maximumSize = min(size.height, size.height) / 2;

    double arcHeight;
    if (shape.side.isHorizontal) {
      arcHeight = shape.arcHeight
          .toPX(constraintSize: size.height)
          .clamp(0, maximumSize);
    } else {
      arcHeight = shape.arcHeight
          .toPX(constraintSize: size.width)
          .clamp(0, maximumSize);
    }

    Offset position;
    Function dragOffsetToDelta;
    switch (shape.side) {
      case ShapeSide.top:
        {
          position = Offset(size.width / 2, arcHeight);
          dragOffsetToDelta = (Offset o) => o.dy;
        }
        break;
      case ShapeSide.bottom:
        {
          position = Offset(size.width / 2, size.height - arcHeight);
          dragOffsetToDelta = (Offset o) => -o.dy;
        }
        break;
      case ShapeSide.left:
        {
          position = Offset(arcHeight, size.height / 2);
          dragOffsetToDelta = (Offset o) => o.dx;
        }
        break;
      case ShapeSide.right: //right
        {
          position = Offset(size.width - arcHeight, size.height / 2);
          dragOffsetToDelta = (Offset o) => -o.dx;
        }
        break;
    }

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: position,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            currentShape = shape.copyWith(
                arcHeight: updateLength(shape.arcHeight, arcHeight,
                    constraintSize:
                        shape.side.isHorizontal ? size.height : size.width,
                    offset: details.delta,
                    offsetToDelta: dragOffsetToDelta));
          });
        }));

    return nodeControls;
  }

  List<Widget> buildCircleEditingWidgets(CircleShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    double startAngle = shape.startAngle.clamp(0.0, 2 * pi);
    double sweepAngle = shape.sweepAngle.clamp(0.0, 2 * pi);

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(size.width / 2 * (1 + cos(startAngle)),
            size.height / 2 * (1 + sin(startAngle))),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            Offset delta = details.delta;
            currentShape = shape.copyWith(
                startAngle: startAngle +
                    (delta.dy * cos(startAngle) - delta.dx * sin(startAngle)) /
                        (Offset(size.width / 2 * cos(startAngle),
                                size.height / 2 * sin(startAngle))
                            .distance));
          });
        }));

    double endAngle = startAngle + sweepAngle;
    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(size.width / 2 * (1 + 1 / 2 * cos(endAngle)),
            size.height / 2 * (1 + 1 / 2 * sin(endAngle))),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            Offset delta = details.delta;
            currentShape = shape.copyWith(
                sweepAngle: sweepAngle +
                    (delta.dy * cos(endAngle) - delta.dx * sin(endAngle)) /
                        (Offset(size.width / 4 * cos(endAngle),
                                size.height / 4 * sin(endAngle))
                            .distance));
          });
        }));

    return nodeControls;
  }

  List<Widget> buildBubbleEditingWidgets(BubbleShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;
    ShapeCorner corner = shape.corner;
    double borderRadius;
    double arrowHeight;
    double arrowWidth;
    double arrowCenterPosition;
    double arrowHeadPosition;
    borderRadius =
        shape.borderRadius.toPX(constraintSize: min(size.height, size.width));
    if (corner.isHorizontal) {
      arrowHeight = shape.arrowHeight.toPX(constraintSize: size.height);
      arrowWidth = shape.arrowWidth.toPX(constraintSize: size.width);
      arrowCenterPosition =
          shape.arrowCenterPosition.toPX(constraintSize: size.width);
      arrowHeadPosition =
          shape.arrowHeadPosition.toPX(constraintSize: size.width);
    } else {
      arrowHeight = shape.arrowHeight.toPX(constraintSize: size.width);
      arrowWidth = shape.arrowWidth.toPX(constraintSize: size.height);
      arrowCenterPosition =
          shape.arrowCenterPosition.toPX(constraintSize: size.height);
      arrowHeadPosition =
          shape.arrowHeadPosition.toPX(constraintSize: size.height);
    }

    final double spacingLeft = shape.corner.isLeft ? arrowHeight : 0;
    final double spacingTop = shape.corner.isTop ? arrowHeight : 0;
    final double spacingRight = shape.corner.isRight ? arrowHeight : 0;
    final double spacingBottom = shape.corner.isBottom ? arrowHeight : 0;

    /*
    if (shape.corner.isHorizontalRight) {
      arrowCenterPosition = size.width - arrowCenterPosition;
      arrowHeadPosition = size.width - arrowHeadPosition;
    }
    if (shape.corner.isVerticalBottom) {
      arrowCenterPosition = size.height - arrowCenterPosition;
      arrowHeadPosition = size.height - arrowHeadPosition;
    }
    */

    final double left = spacingLeft;
    final double top = spacingTop;
    final double right = size.width - spacingRight;
    final double bottom = size.height - spacingBottom;

    double radiusBound = 0;

    if (shape.corner.isHorizontal) {
      arrowCenterPosition = arrowCenterPosition.clamp(0.0, size.width);
      arrowHeadPosition = arrowHeadPosition.clamp(0.0, size.width);
      arrowWidth = arrowWidth.clamp(
          0.0, 2 * min(arrowCenterPosition, size.width - arrowCenterPosition));
      radiusBound = min(
          min(right - arrowCenterPosition - arrowWidth / 2,
              arrowCenterPosition - arrowWidth / 2 - left),
          (bottom - top) / 2);
      borderRadius =
          borderRadius.clamp(0.0, radiusBound >= 0.0 ? radiusBound : 0.0);
    } else {
      arrowCenterPosition = arrowCenterPosition.clamp(0.0, size.height);
      arrowHeadPosition = arrowHeadPosition.clamp(0.0, size.height);
      arrowWidth = arrowWidth.clamp(
          0.0, 2 * min(arrowCenterPosition, size.height - arrowCenterPosition));
      radiusBound = min(
          min(bottom - arrowCenterPosition - arrowWidth / 2,
              arrowCenterPosition - arrowWidth / 2 - top),
          (right - left) / 2);
      borderRadius = borderRadius.clamp(
        0.0,
        radiusBound >= 0.0 ? radiusBound : 0.0,
      );
    }

    Function arrowHeadDragUpdate,
        arrowCenterDragUpdateHorizontal,
        arrowCenterDragUpdateVertical,
        arrowWidthDragUpdate,
        radiusDragUpdate;
    Offset arrowHeadOffset, arrowCenterOffset, arrowWidthOffset, radiusOffset;
    switch (shape.corner) {
      case ShapeCorner.topLeft:
        {
          arrowHeadOffset = Offset(arrowHeadPosition, 0);
          arrowCenterOffset = Offset(arrowCenterPosition, top);
          arrowWidthOffset = Offset(
              (arrowCenterPosition - arrowWidth / 2).clamp(0.0, size.width),
              top);
          arrowHeadDragUpdate = (Offset o) => o.dx;
          arrowWidthDragUpdate = (Offset o) => -2 * o.dx;
          arrowCenterDragUpdateHorizontal = (Offset o) => o.dx;
          arrowCenterDragUpdateVertical = (Offset o) => o.dy;
          radiusOffset =
              Offset(size.width - borderRadius, size.height - borderRadius);
          radiusDragUpdate = (Offset o) => -o.dx;
        }
        break;
      case ShapeCorner.topRight:
        {
          arrowHeadOffset = Offset(size.width - arrowHeadPosition, 0);
          arrowCenterOffset = Offset(size.width - arrowCenterPosition, top);
          arrowWidthOffset = Offset(
              (size.width - arrowCenterPosition - arrowWidth / 2)
                  .clamp(0.0, size.width),
              top);
          arrowHeadDragUpdate = (Offset o) => -o.dx;
          arrowWidthDragUpdate = (Offset o) => -2 * o.dx;
          arrowCenterDragUpdateHorizontal = (Offset o) => -o.dx;
          arrowCenterDragUpdateVertical = (Offset o) => o.dy;

          radiusOffset = Offset(size.width - borderRadius, size.height);
          radiusDragUpdate = (Offset o) => -o.dx;
        }
        break;
      case ShapeCorner.bottomLeft:
        {
          arrowHeadOffset = Offset(arrowHeadPosition, size.height);
          arrowCenterOffset = Offset(arrowCenterPosition, bottom);
          arrowWidthOffset = Offset(
              (arrowCenterPosition - arrowWidth / 2).clamp(0.0, size.width),
              bottom);
          arrowHeadDragUpdate = (Offset o) => o.dx;
          arrowWidthDragUpdate = (Offset o) => -2 * o.dx;
          arrowCenterDragUpdateHorizontal = (Offset o) => o.dx;
          arrowCenterDragUpdateVertical = (Offset o) => -o.dy;

          radiusOffset = Offset(borderRadius, 0);
          radiusDragUpdate = (Offset o) => o.dx;
        }
        break;
      case ShapeCorner.bottomRight:
        {
          arrowHeadOffset = Offset(size.width - arrowHeadPosition, size.height);
          arrowCenterOffset = Offset(size.width - arrowCenterPosition, bottom);
          arrowWidthOffset = Offset(
              (size.width - arrowCenterPosition - arrowWidth / 2)
                  .clamp(0.0, size.width),
              bottom);
          arrowHeadDragUpdate = (Offset o) => -o.dx;
          arrowWidthDragUpdate = (Offset o) => -2 * o.dx;
          arrowCenterDragUpdateHorizontal = (Offset o) => -o.dx;
          arrowCenterDragUpdateVertical = (Offset o) => -o.dy;

          radiusOffset = Offset(borderRadius, 0);
          radiusDragUpdate = (Offset o) => o.dx;
        }
        break;
      case ShapeCorner.leftTop:
        {
          arrowHeadOffset = Offset(0, arrowHeadPosition);
          arrowCenterOffset = Offset(left, arrowCenterPosition);
          arrowWidthOffset = Offset(left,
              (arrowCenterPosition - arrowWidth / 2).clamp(0.0, size.height));
          arrowHeadDragUpdate = (Offset o) => o.dy;
          arrowWidthDragUpdate = (Offset o) => -2 * o.dy;
          arrowCenterDragUpdateHorizontal = (Offset o) => o.dy;
          arrowCenterDragUpdateVertical = (Offset o) => o.dx;

          radiusOffset = Offset(size.width, borderRadius);
          radiusDragUpdate = (Offset o) => o.dy;
        }
        break;
      case ShapeCorner.leftBottom:
        {
          arrowHeadOffset = Offset(0, size.height - arrowHeadPosition);
          arrowCenterOffset = Offset(left, size.height - arrowCenterPosition);
          arrowWidthOffset = Offset(
              left,
              (size.height - arrowCenterPosition - arrowWidth / 2)
                  .clamp(0.0, size.height));
          arrowHeadDragUpdate = (Offset o) => -o.dy;
          arrowWidthDragUpdate = (Offset o) => -2 * o.dy;
          arrowCenterDragUpdateHorizontal = (Offset o) => -o.dy;
          arrowCenterDragUpdateVertical = (Offset o) => o.dx;

          radiusOffset = Offset(size.width, borderRadius);
          radiusDragUpdate = (Offset o) => o.dy;
        }
        break;
      case ShapeCorner.rightTop:
        {
          arrowHeadOffset = Offset(size.width, arrowHeadPosition);
          arrowCenterOffset = Offset(right, arrowCenterPosition);
          arrowWidthOffset = Offset(right,
              (arrowCenterPosition - arrowWidth / 2).clamp(0.0, size.height));
          arrowHeadDragUpdate = (Offset o) => o.dy;
          arrowWidthDragUpdate = (Offset o) => -2 * o.dy;
          arrowCenterDragUpdateHorizontal = (Offset o) => o.dy;
          arrowCenterDragUpdateVertical = (Offset o) => -o.dx;

          radiusOffset = Offset(0, borderRadius);
          radiusDragUpdate = (Offset o) => o.dy;
        }
        break;
      case ShapeCorner.rightBottom:
        {
          arrowHeadOffset = Offset(size.width, size.height - arrowHeadPosition);
          arrowCenterOffset = Offset(right, size.height - arrowCenterPosition);
          arrowWidthOffset = Offset(
              right,
              (size.height - arrowCenterPosition - arrowWidth / 2)
                  .clamp(0.0, size.height));
          arrowHeadDragUpdate = (Offset o) => -o.dy;
          arrowWidthDragUpdate = (Offset o) => -2 * o.dy;
          arrowCenterDragUpdateHorizontal = (Offset o) => -o.dy;
          arrowCenterDragUpdateVertical = (Offset o) => -o.dx;

          radiusOffset = Offset(0, borderRadius);
          radiusDragUpdate = (Offset o) => o.dy;
        }
        break;
    }

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: arrowCenterOffset,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            currentShape = shape.copyWith(
                arrowHeight: updateLength(shape.arrowHeight, arrowHeight,
                    constraintSize:
                        shape.corner.isHorizontal ? size.height : size.width,
                    offset: details.delta,
                    offsetToDelta: arrowCenterDragUpdateVertical),
                arrowCenterPosition: updateLength(
                    shape.arrowCenterPosition, arrowCenterPosition,
                    constraintSize:
                        shape.corner.isHorizontal ? size.width : size.height,
                    offset: details.delta,
                    offsetToDelta: arrowCenterDragUpdateHorizontal));
          });
        }));
    nodeControls.add(dynamicShapeEditingDragWidget(
        position: arrowWidthOffset,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            currentShape = shape.copyWith(
                arrowWidth: updateLength(shape.arrowWidth, arrowWidth,
                    constraintSize:
                        shape.corner.isHorizontal ? size.width : size.height,
                    offset: details.delta,
                    offsetToDelta: arrowWidthDragUpdate));
          });
        }));
    nodeControls.add(dynamicShapeEditingDragWidget(
        position: arrowHeadOffset,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            currentShape = shape.copyWith(
                arrowHeadPosition: updateLength(
                    shape.arrowHeadPosition, arrowHeadPosition,
                    constraintSize:
                        shape.corner.isHorizontal ? size.width : size.height,
                    offset: details.delta,
                    offsetToDelta: arrowHeadDragUpdate));
          });
        }));
    nodeControls.add(dynamicShapeEditingDragWidget(
        position: radiusOffset,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            currentShape = shape.copyWith(
                borderRadius: updateLength(shape.borderRadius, borderRadius,
                    constraintSize: min(size.width, size.height),
                    offset: details.delta,
                    offsetToDelta: radiusDragUpdate));
          });
        }));

    return nodeControls;
  }

  List<Widget> buildDiagonalEditingWidgets(DiagonalShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    final width = size.width;
    final height = size.height;

    double inset;
    if (shape.corner.isHorizontal) {
      inset = shape.inset.toPX(constraintSize: height).clamp(0, height);
    } else {
      inset = shape.inset.toPX(constraintSize: width).clamp(0, width);
    }

    Offset position;
    Function onDragUpdate;
    switch (shape.corner) {
      case ShapeCorner.bottomRight:
        position = Offset(width, height - inset);
        onDragUpdate = (Offset o) => -o.dy;
        break;
      case ShapeCorner.bottomLeft:
        position = Offset(0, height - inset);
        onDragUpdate = (Offset o) => -o.dy;
        break;
      case ShapeCorner.topLeft:
        position = Offset(width, height - inset);
        onDragUpdate = (Offset o) => o.dy;
        break;
      case ShapeCorner.topRight:
        position = Offset(width, height - inset);
        onDragUpdate = (Offset o) => o.dy;
        break;
      case ShapeCorner.leftTop:
        position = Offset(inset, 0);
        onDragUpdate = (Offset o) => o.dx;
        break;
      case ShapeCorner.leftBottom:
        position = Offset(inset, height);
        onDragUpdate = (Offset o) => o.dx;
        break;
      case ShapeCorner.rightTop:
        position = Offset(width - inset, 0);
        onDragUpdate = (Offset o) => -o.dx;
        break;
      case ShapeCorner.rightBottom:
        position = Offset(width - inset, height);
        onDragUpdate = (Offset o) => -o.dx;
        break;
    }

    nodeControls.add(dynamicShapeEditingDragWidget(
      position: position,
      onDragUpdate: (DragUpdateDetails details) {
        setState(() {
          currentShape = shape.copyWith(
              inset: updateLength(shape.inset, inset,
                  constraintSize:
                      shape.corner.isHorizontal ? size.height : size.width,
                  offset: details.delta,
                  offsetToDelta: onDragUpdate));
        });
      },
    ));

    return nodeControls;
  }

  List<Widget> buildCutCornerEditingWidgets(CutCornerShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    BorderRadius borderRadius = shape.borderRadius.toBorderRadius(size);

    final topLeftRadius = borderRadius.topLeft.x.clamp(0, size.width / 2);
    final topRightRadius = borderRadius.topRight.x.clamp(0, size.width / 2);
    final bottomLeftRadius = borderRadius.bottomLeft.x.clamp(0, size.width / 2);
    final bottomRightRadius =
        borderRadius.bottomRight.x.clamp(0, size.width / 2);

    final leftTopRadius = borderRadius.topLeft.y.clamp(0, size.height / 2);
    final rightTopRadius = borderRadius.topRight.y.clamp(0, size.height / 2);
    final leftBottomRadius =
        borderRadius.bottomLeft.y.clamp(0, size.height / 2);
    final rightBottomRadius =
        borderRadius.bottomRight.y.clamp(0, size.height / 2);

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(topLeftRadius, 0),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topLeft.copyWith(
                x: updateLength(shape.borderRadius.topLeft.x, topLeftRadius,
                    constraintSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dx));

            currentShape = shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topLeft: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(size.width - topRightRadius, 0),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topRight.copyWith(
                x: updateLength(shape.borderRadius.topRight.x, topRightRadius,
                    constraintSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dx));

            currentShape = shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topRight: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(bottomLeftRadius, size.height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomLeft.copyWith(
                x: updateLength(
                    shape.borderRadius.bottomLeft.x, bottomLeftRadius,
                    constraintSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dx));

            currentShape = shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomLeft: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(size.width - bottomRightRadius, size.height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomRight.copyWith(
                x: updateLength(
                    shape.borderRadius.bottomRight.x, bottomRightRadius,
                    constraintSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dx));

            currentShape = shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomRight: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(0, leftTopRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topLeft.copyWith(
                y: updateLength(shape.borderRadius.topLeft.y, leftTopRadius,
                    constraintSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dy));

            currentShape = shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topLeft: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(size.width, rightTopRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topRight.copyWith(
                y: updateLength(shape.borderRadius.topRight.y, rightTopRadius,
                    constraintSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dy));

            currentShape = shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topRight: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(0, size.height - leftBottomRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomLeft.copyWith(
                y: updateLength(
                    shape.borderRadius.bottomLeft.y, leftBottomRadius,
                    constraintSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dy));

            currentShape = shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomLeft: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(size.width, size.height - rightBottomRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomRight.copyWith(
                y: updateLength(
                    shape.borderRadius.bottomRight.y, rightBottomRadius,
                    constraintSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dy));

            currentShape = shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomRight: newRadius));
          });
        }));

    return nodeControls;
  }

  List<Widget> buildRoundRectEditingWidgets(RoundRectShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    BorderRadius borderRadius = shape.borderRadius.toBorderRadius(size);

    final topLeftRadius = borderRadius.topLeft.x.clamp(0, size.width / 2);
    final topRightRadius = borderRadius.topRight.x.clamp(0, size.width / 2);
    final bottomLeftRadius = borderRadius.bottomLeft.x.clamp(0, size.width / 2);
    final bottomRightRadius =
        borderRadius.bottomRight.x.clamp(0, size.width / 2);

    final leftTopRadius = borderRadius.topLeft.y.clamp(0, size.height / 2);
    final rightTopRadius = borderRadius.topRight.y.clamp(0, size.height / 2);
    final leftBottomRadius =
        borderRadius.bottomLeft.y.clamp(0, size.height / 2);
    final rightBottomRadius =
        borderRadius.bottomRight.y.clamp(0, size.height / 2);

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(topLeftRadius, 0),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topLeft.copyWith(
                x: updateLength(shape.borderRadius.topLeft.x, topLeftRadius,
                    constraintSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dx));

            currentShape = shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topLeft: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(size.width - topRightRadius, 0),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topRight.copyWith(
                x: updateLength(shape.borderRadius.topRight.x, topRightRadius,
                    constraintSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dx));

            currentShape = shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topRight: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(bottomLeftRadius, size.height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomLeft.copyWith(
                x: updateLength(
                    shape.borderRadius.bottomLeft.x, bottomLeftRadius,
                    constraintSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dx));

            currentShape = shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomLeft: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(size.width - bottomRightRadius, size.height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomRight.copyWith(
                x: updateLength(
                    shape.borderRadius.bottomRight.x, bottomRightRadius,
                    constraintSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dx));

            currentShape = shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomRight: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(0, leftTopRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topLeft.copyWith(
                y: updateLength(shape.borderRadius.topLeft.y, leftTopRadius,
                    constraintSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dy));

            currentShape = shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topLeft: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(size.width, rightTopRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topRight.copyWith(
                y: updateLength(shape.borderRadius.topRight.y, rightTopRadius,
                    constraintSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dy));

            currentShape = shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topRight: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(0, size.height - leftBottomRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomLeft.copyWith(
                y: updateLength(
                    shape.borderRadius.bottomLeft.y, leftBottomRadius,
                    constraintSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dy));

            currentShape = shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomLeft: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(size.width, size.height - rightBottomRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomRight.copyWith(
                y: updateLength(
                    shape.borderRadius.bottomRight.y, rightBottomRadius,
                    constraintSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dy));

            currentShape = shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomRight: newRadius));
          });
        }));

    return nodeControls;
  }

  List<Widget> buildPolygonEditingWidgets(PolygonShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    double scale = min(size.width, size.height);
    double cornerRadius = shape.cornerRadius.toPX(constraintSize: scale);
    int sides = shape.sides;

    final height = scale;
    final width = scale;

    double startAngle = -pi / 2;

    final double section = (2.0 * pi / sides);
    final double polygonSize = min(width, height);
    final double radius = polygonSize / 2;
    final double centerX = width / 2;
    final double centerY = height / 2;

    cornerRadius = cornerRadius.clamp(0, radius * cos(section / 2));

    double arcCenterRadius = radius - cornerRadius / sin(pi / 2 - section / 2);

    double arcCenterX = (centerX + arcCenterRadius * cos(startAngle));
    double arcCenterY = (centerY + arcCenterRadius * sin(startAngle));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(arcCenterX, arcCenterY)
            .scale(size.width / width, size.height / height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            currentShape = shape.copyWith(
                cornerRadius: updateLength(shape.cornerRadius, cornerRadius,
                    constraintSize: scale,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dy));
          });
        }));

    return nodeControls;
  }

  List<Widget> buildStarEditingWidgets(StarShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    double scale = min(size.width, size.height);
    double cornerRadius = shape.cornerRadius.toPX(constraintSize: scale);
    double insetRadius = shape.insetRadius.toPX(constraintSize: scale);

    final height = scale;
    final width = scale;

    final int vertices = shape.corners * 2;
    final double alpha = (2 * pi) / vertices;
    final double radius = scale / 2;
    final double centerX = width / 2;
    final double centerY = height / 2;

    double inset = shape.inset.toPX(constraintSize: radius);
    inset = inset.clamp(5.0, radius);
    double sideLength = getThirdSideLength(radius, radius - inset, alpha);
    double beta = getThirdAngle(sideLength, radius, radius - inset);
    double gamma = alpha + beta;

    cornerRadius = cornerRadius.clamp(0, sideLength * tan(beta));
    double avalSideLength = max(sideLength - cornerRadius / tan(beta), 0.0);

    if (gamma <= pi / 2) {
      insetRadius = insetRadius.clamp(0, avalSideLength * tan(gamma));
    } else {
      insetRadius = insetRadius.clamp(0, avalSideLength * tan(pi - gamma));
    }

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(centerX,
                centerY - radius + cornerRadius / sin(beta) - cornerRadius)
            .scale(size.width / width, size.height / height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            currentShape = shape.copyWith(
                cornerRadius: updateLength(shape.cornerRadius, cornerRadius,
                    constraintSize: scale,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dy * sin(beta)));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(centerX + (radius - inset) * cos(-pi / 2 + alpha),
                centerY + (radius - inset) * sin(-pi / 2 + (alpha)))
            .scale(size.width / width, size.height / height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            currentShape = shape.copyWith(
                inset: updateLength(shape.inset, inset,
                    constraintSize: scale,
                    offset: details.delta,
                    offsetToDelta: (o) => (-o.dx / cos(-pi / 2 + alpha))));
          });
        }));

    double sweepAngle = pi - 2 * gamma;
    print(shape.insetRadius.toJson());
    if (gamma <= pi / 2) {
      double r = radius - inset + insetRadius / sin(gamma) - insetRadius;
      nodeControls.add(dynamicShapeEditingDragWidget(
          position: Offset(centerX + r * cos(-pi / 2 - alpha),
                  centerY + r * sin(-pi / 2 - alpha))
              .scale(size.width / width, size.height / height),
          onDragUpdate: (DragUpdateDetails details) {
            setState(() {
              currentShape = shape.copyWith(
                  insetRadius: updateLength(shape.insetRadius, insetRadius,
                      constraintSize: scale,
                      offset: details.delta,
                      offsetToDelta: (o) =>
                          (o.dx / cos(-pi / 2 - alpha) / cos(sweepAngle / 2))));
            });
          }));
    } else {
      //sweepAngle = -sweepAngle;
      double r = radius - inset - insetRadius / sin(gamma) + insetRadius;
      nodeControls.add(dynamicShapeEditingDragWidget(
          position: Offset(centerX + r * cos(-pi / 2 - alpha),
                  centerY + r * sin(-pi / 2 - alpha))
              .scale(size.width / width, size.height / height),
          onDragUpdate: (DragUpdateDetails details) {
            setState(() {
              currentShape = shape.copyWith(
                  insetRadius: updateLength(shape.insetRadius, insetRadius,
                      constraintSize: scale,
                      offset: details.delta,
                      offsetToDelta: (o) => (-o.dx /
                          cos(-pi / 2 - alpha) /
                          cos(sweepAngle / 2))));
            });
          }));
    }

    return nodeControls;
  }

  List<Widget> buildTriangleEditingWidgets(TriangleShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    final width = size.width;
    final height = size.height;

    Offset point3 =
        shape.point3.toOffset(size).clamp(Offset.zero, Offset(width, height));
    Offset point2 =
        shape.point2.toOffset(size).clamp(Offset.zero, Offset(width, height));
    Offset point1 =
        shape.point1.toOffset(size).clamp(Offset.zero, Offset(width, height));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: point3,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicOffset newOffset = shape.point3.copyWith(
                dx: updateLength(shape.point3.dx, point3.dx,
                    constraintSize: width,
                    maximumSize: width,
                    offset: details.delta,
                    offsetToDelta: (o) => (o.dx)),
                dy: updateLength(shape.point3.dy, point3.dy,
                    constraintSize: height,
                    maximumSize: height,
                    offset: details.delta,
                    offsetToDelta: (o) => (o.dy)));
            currentShape = shape.copyWith(point3: newOffset);
          });
        }));
    nodeControls.add(dynamicShapeEditingDragWidget(
        position: point2,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicOffset newOffset = shape.point2.copyWith(
                dx: updateLength(shape.point2.dx, point2.dx,
                    constraintSize: width,
                    maximumSize: width,
                    offset: details.delta,
                    offsetToDelta: (o) => (o.dx)),
                dy: updateLength(shape.point2.dy, point2.dy,
                    constraintSize: height,
                    maximumSize: height,
                    offset: details.delta,
                    offsetToDelta: (o) => (o.dy)));
            currentShape = shape.copyWith(point2: newOffset);
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: point1,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicOffset newOffset = shape.point1.copyWith(
                dx: updateLength(shape.point1.dx, point1.dx,
                    constraintSize: width,
                    maximumSize: width,
                    offset: details.delta,
                    offsetToDelta: (o) => (o.dx)),
                dy: updateLength(shape.point1.dy, point1.dy,
                    constraintSize: height,
                    maximumSize: height,
                    offset: details.delta,
                    offsetToDelta: (o) => (o.dy)));
            currentShape = shape.copyWith(point1: newOffset);
          });
        }));

    return nodeControls;
  }

  List<Widget> buildPathEditingPanelWidget(PathShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    DynamicPath path=shape.path;
    path.resize(shapeSize);

    if(selectedNodeIndex!=null) {
      rst.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Side"),
          OffsetPicker(position: path.nodes[selectedNodeIndex].position, onPositionChanged: (Offset newPos) {
            setState(() {
              print("new pos: "+newPos.toString());
              path.moveNodeTo(selectedNodeIndex,newPos);
              currentShape=shape.copyWith(path: path);
            });
          },
          constraintSize: shapeSize,)
        ],
      ));
    }
    return rst;
  }

  List<Widget> buildArcEditingPanelWidget(ArcShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Side"),
        DropdownButton<ShapeSide>(
            value: shape.side,
            onChanged: (ShapeSide newSide) {
              setState(() {
                currentShape = shape.copyWith(side: newSide);
              });
            },
            items: ShapeSide.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.toJson())))
                .toList())
      ],
    ));

    rst.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Outward"),
        Checkbox(
            value: shape.isOutward,
            onChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(isOutward: value);
              });
            })
      ],
    ));

    rst.add(Row(
      children: [
        Text("Arc Height"),
        Expanded(
          child: LengthSlider(
            sliderValue: shape.arcHeight,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(arcHeight: value);
              });
            },
            constraintSize: shape.side.isHorizontal ? size.height : size.width,
            allowedUnits: ["px", "%"],
          ),
        ),
      ],
    ));

    return rst;
  }

  List<Widget> buildBubbleEditingPanelWidget(BubbleShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Corner"),
        DropdownButton<ShapeCorner>(
            value: shape.corner,
            onChanged: (ShapeCorner value) {
              setState(() {
                currentShape = shape.copyWith(corner: value);
              });
            },
            items: ShapeCorner.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.toJson())))
                .toList())
      ],
    ));

    rst.add(Row(
      children: [
        Text("Arrow Center"),
        Expanded(
          child: LengthSlider(
            sliderValue: shape.arrowCenterPosition,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(arrowCenterPosition: value);
              });
            },
            constraintSize:
                shape.corner.isHorizontal ? size.width : size.height,
            allowedUnits: ["px", "%"],
          ),
        ),
      ],
    ));

    rst.add(Row(
      children: [
        Text("Arrow Head"),
        Expanded(
          child: LengthSlider(
            sliderValue: shape.arrowHeadPosition,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(arrowHeadPosition: value);
              });
            },
            constraintSize:
                shape.corner.isHorizontal ? size.width : size.height,
            allowedUnits: ["px", "%"],
          ),
        ),
      ],
    ));

    rst.add(Row(
      children: [
        Text("Arrow Height"),
        Expanded(
          child: LengthSlider(
            sliderValue: shape.arrowHeight,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(arrowHeight: value);
              });
            },
            constraintSize:
                shape.corner.isHorizontal ? size.height : size.width,
            allowedUnits: ["px", "%"],
          ),
        ),
      ],
    ));

    rst.add(Row(
      children: [
        Text("Arrow Width"),
        Expanded(
          child: LengthSlider(
            sliderValue: shape.arrowWidth,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(arrowWidth: value);
              });
            },
            constraintSize:
                shape.corner.isHorizontal ? size.width : size.height,
            allowedUnits: ["px", "%"],
          ),
        ),
      ],
    ));

    rst.add(Row(
      children: [
        Text("Border Radius"),
        Expanded(
          child: LengthSlider(
            sliderValue: shape.borderRadius,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(borderRadius: value);
              });
            },
            constraintSize: min(size.width, size.height),
            allowedUnits: ["px", "%"],
          ),
        ),
      ],
    ));

    return rst;
  }

  List<Widget> buildCircleEditingPanelWidget(CircleShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Start Angle"),
        Slider(
          value: shape.startAngle / pi * 180.clamp(0, 360),
          min: 0,
          max: 360,
          divisions: 72,
          label: (shape.startAngle / pi * 180.clamp(0, 360)).toStringAsFixed(0),
          onChanged: (value) {
            setState(() {
              currentShape = shape.copyWith(startAngle: value / 180 * pi);
            });
          },
        )
      ],
    ));

    rst.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Sweep Angle"),
        Slider(
          value: shape.sweepAngle / pi * 180.clamp(0, 360),
          min: 0,
          max: 360,
          divisions: 72,
          label: (shape.sweepAngle / pi * 180.clamp(0, 360)).toStringAsFixed(0),
          onChanged: (value) {
            setState(() {
              currentShape = shape.copyWith(sweepAngle: value / 180 * pi);
            });
          },
        )
      ],
    ));

    return rst;
  }

  List<Widget> buildCutCornerEditingPanelWidget(CutCornerShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(Row(
      children: [
        Text("Top Left"),
        Expanded(
          child: LengthSlider(
            sliderValue: shape.borderRadius.topLeft.x,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(
                    borderRadius: shape.borderRadius.copyWith(
                        topLeft:
                            shape.borderRadius.topLeft.copyWith(x: value)));
              });
            },
            constraintSize: size.width,
            allowedUnits: ["px", "%"],
          ),
        ),
      ],
    ));

    rst.add(Row(
      children: [
        Text("Top Right"),
        Expanded(
          child: LengthSlider(
            sliderValue: shape.borderRadius.topRight.x,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(
                    borderRadius: shape.borderRadius.copyWith(
                        topRight:
                            shape.borderRadius.topRight.copyWith(x: value)));
              });
            },
            constraintSize: size.width,
            allowedUnits: ["px", "%"],
          ),
        ),
      ],
    ));

    rst.add(Row(
      children: [
        Text("Bottom Left"),
        Expanded(
          child: LengthSlider(
            sliderValue: shape.borderRadius.bottomLeft.x,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(
                    borderRadius: shape.borderRadius.copyWith(
                        bottomLeft:
                            shape.borderRadius.bottomLeft.copyWith(x: value)));
              });
            },
            constraintSize: size.width,
            allowedUnits: ["px", "%"],
          ),
        ),
      ],
    ));

    rst.add(Row(
      children: [
        Text("Bottom Right"),
        Expanded(
          child: LengthSlider(
            sliderValue: shape.borderRadius.bottomRight.x,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(
                    borderRadius: shape.borderRadius.copyWith(
                        bottomRight:
                            shape.borderRadius.bottomRight.copyWith(x: value)));
              });
            },
            constraintSize: size.width,
            allowedUnits: ["px", "%"],
          ),
        ),
      ],
    ));

    return rst;
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
                  Offset(details.delta.dx * alignX, details.delta.dy * alignY) *
                      2;
              //shape.resize(shapeSize);
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
