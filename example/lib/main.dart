import 'dart:math';
import 'dart:convert';

import 'package:example/morph_shape_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:morphable_shape/borderShapes/bubble.dart';
import 'package:morphable_shape/borderShapes/circle.dart';
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
  static double nodeSize = 8;
  static int gridCount = 30;

  Shape currentShape;

  Size shapeSize;
  int selectedNodeIndex;
  bool isEditingPath = false;

  Axis direction;

  @override
  void initState() {
    super.initState();
    currentShape = RectangleShape(
        borderRadius: DynamicBorderRadius.all(
           DynamicRadius.elliptical(50.0.toPXLength, 50.0.toPXLength)));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      Size screenSize = MediaQuery.of(context).size;

      if (screenSize.width > screenSize.height) {
        direction = Axis.horizontal;
      } else {
        direction = Axis.vertical;
      }

      if (shapeSize == null) {
        double length = (min(screenSize.width, screenSize.height) * 0.8)
            .clamp(200.0, 400.0);
        shapeSize = Size(length, length);
      }

      MorphableShapeBorder shapeBorder;

      shapeBorder = MorphableShapeBorder(
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
            shape: shapeBorder,
            clipBehavior: Clip.antiAlias,
            animationDuration: Duration.zero,
            //elevation: 10,
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
            title: Text("Edit Shape: " + currentShape.runtimeType.toString()),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
                icon: Icon(Icons.remove_red_eye),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MorphShapePage(
                                shape: currentShape,
                              )));
                }),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.code),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: SingleChildScrollView(
                            child: Container(
                                width: min(screenSize.width * 0.8, 400),
                                child: SelectableText(
                                    json.encode(currentShape.toJson()))),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Got it'),
                              onPressed: () {
                                Navigator.of(context)?.pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }),
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
                Container(
                  width: isEditingPath
                      ? (direction == Axis.horizontal
                          ? 360.0
                          : screenSize.width)
                      : 0,
                  height: isEditingPath
                      ? (direction == Axis.horizontal ? screenSize.height : 360)
                      : 0,
                  decoration: BoxDecoration(color: Colors.grey, boxShadow: [
                    BoxShadow(
                        offset: Offset(-2, 2),
                        color: Colors.black54,
                        blurRadius: 6,
                        spreadRadius: 0)
                  ]),
                  padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                  child: ListView(
                    children: buildEditingShapeDirectWidgets(),
                  ),
                )
              ],
            ),
          ));
    });
  }

  List<Widget> buildEditingShapeControlWidgets() {
    List<Widget> stackedComponents = [];
    if (currentShape is ArcShape) {
      stackedComponents.addAll(buildArcEditingWidgets(currentShape));
    }
    if (currentShape is ArrowShape) {
      stackedComponents.addAll(buildArrowEditingWidgets(currentShape));
    }
    if (currentShape is BubbleShape) {
      stackedComponents.addAll(buildBubbleEditingWidgets(currentShape));
    }
    if (currentShape is CircleShape) {
      stackedComponents.addAll(buildCircleEditingWidgets(currentShape));
    }

    if (currentShape is PathShape) {
      stackedComponents.addAll(buildPathEditingWidgets(currentShape));
    }
    if (currentShape is PolygonShape) {
      stackedComponents.addAll(buildPolygonEditingWidgets(currentShape));
    }

    if (currentShape is RectangleShape) {
      stackedComponents.addAll(buildRectangleEditingWidgets(currentShape));
    }

    if (currentShape is StarShape) {
      stackedComponents.addAll(buildStarEditingWidgets(currentShape));
    }

    if (currentShape is TrapezoidShape) {
      stackedComponents.addAll(buildTrapezoidEditingWidgets(currentShape));
    }

    if (currentShape is TriangleShape) {
      stackedComponents.addAll(buildTriangleEditingWidgets(currentShape));
    }

    return stackedComponents;
  }

  List<Widget> buildEditingShapeDirectWidgets() {
    List<Widget> stackedComponents = [];

    if (currentShape is ArcShape) {
      stackedComponents.addAll(buildArcEditingPanelWidget(currentShape));
    }

    if (currentShape is ArrowShape) {
      stackedComponents.addAll(buildArrowEditingPanelWidget(currentShape));
    }

    if (currentShape is BubbleShape) {
      stackedComponents.addAll(buildBubbleEditingPanelWidget(currentShape));
    }

    if (currentShape is CircleShape) {
      stackedComponents.addAll(buildCircleEditingPanelWidget(currentShape));
    }

    if (currentShape is PathShape) {
      stackedComponents.addAll(buildPathEditingPanelWidget(currentShape));
    }

    if (currentShape is PolygonShape) {
      stackedComponents.addAll(buildPolygonEditingPanelWidget(currentShape));
    }

    if (currentShape is RectangleShape) {
      stackedComponents.addAll(buildRectangleEditingPanelWidget(currentShape));
    }

    if (currentShape is StarShape) {
      stackedComponents.addAll(buildStarEditingPanelWidget(currentShape));
    }

    if (currentShape is TrapezoidShape) {
      stackedComponents.addAll(buildTrapezoidEditingPanelWidget(currentShape));
    }

    if (currentShape is TriangleShape) {
      stackedComponents.addAll(buildTriangleEditingPanelWidget(currentShape));
    }

    stackedComponents.insert(
        0,
        buildRowWithHeaderText(
            headerText: "Shape Size",
            actionWidget: OffsetPicker(
                position: Offset(shapeSize.width, shapeSize.height),
                onPositionChanged: (Offset newPos) {
                  setState(() {
                    shapeSize = Size(newPos.dx, newPos.dy);
                  });
                },
                constraintSize: MediaQuery.of(context).size)));

    stackedComponents.add(buildRowWithHeaderText(
        headerText: "To Bezier",
        actionWidget: Container(
          padding: EdgeInsets.only(right: 5),
          child: ElevatedButton(
              child: Text('CONVERT'),
              style:
                  ElevatedButton.styleFrom(primary: Colors.black87 // foreground
                      ),
              onPressed: () {
                setState(() {
                  currentShape = PathShape(
                      path: currentShape.generateDynamicPath(Rect.fromLTRB(
                          0, 0, shapeSize.width, shapeSize.height)));
                });
              }),
        )));

    stackedComponents.add(buildRowWithHeaderText(
        headerText: "Change Shape",
        actionWidget: Container(
          padding: EdgeInsets.only(right: 5),
          child: BottomSheetShapePicker(
            currentShape: currentShape,
            valueChanged: (value) {
              setState(() {
                currentShape = value;
              });
            },
          ),
        )));

    List<Widget> withDividerWidgets=[];
    stackedComponents.forEach((element) {
      withDividerWidgets.add(element);
      withDividerWidgets.add(Divider(thickness: 2,));
    });

    return withDividerWidgets;
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
                gradient: RadialGradient(colors: [Colors.amber, Colors.amberAccent],stops: [0,0.3]),
                shape: CircleBorder(side: BorderSide(width: 0))),
        alignment: Alignment.center,
        child: Icon(Icons.add, size: 2*nodeSize*0.8,),),
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
                          index, Offset(details.delta.dx, details.delta.dy).roundWithPrecision(2));
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
                      Offset(details.delta.dx, details.delta.dy).roundWithPrecision(2));
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
                      Offset(details.delta.dx, details.delta.dy).roundWithPrecision(2));
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
      {Offset position, Function onDragUpdate, Color color=Colors.amber}) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        dragStartBehavior: DragStartBehavior.start,
        onPanUpdate: onDragUpdate,
        child: Container(
          width: 2 * nodeSize,
          height: 2 * nodeSize,
          decoration: BoxDecoration(
              color: color, border: Border.all(color: Colors.black)),
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

  List<Widget> buildArrowEditingWidgets(ArrowShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    double tailWidth, arrowHeight;
    if (shape.side.isHorizontal) {
      arrowHeight = shape.arrowHeight
          .toPX(constraintSize: size.height)
          .clamp(0, size.height);
      tailWidth =
          shape.tailWidth.toPX(constraintSize: size.width).clamp(0, size.width);
    } else {
      arrowHeight = shape.arrowHeight
          .toPX(constraintSize: size.width)
          .clamp(0, size.width);
      tailWidth = shape.tailWidth
          .toPX(constraintSize: size.height)
          .clamp(0, size.height);
    }

    Offset headPosition, tailPosition;
    Function headOffsetToDelta, tailOffsetToDelta;
    switch (shape.side) {
      case ShapeSide.top:
        {
          headPosition = Offset(size.width, arrowHeight);
          headOffsetToDelta = (Offset o) => o.dy;
          tailPosition = Offset(size.width / 2 + tailWidth / 2, size.height);
          tailOffsetToDelta = (Offset o) => 2 * o.dx;
        }
        break;
      case ShapeSide.bottom:
        {
          headPosition = Offset(size.width, size.height - arrowHeight);
          headOffsetToDelta = (Offset o) => -o.dy;
          tailPosition = Offset(size.width / 2 + tailWidth / 2, 0);
          tailOffsetToDelta = (Offset o) => 2 * o.dx;
        }
        break;
      case ShapeSide.left:
        {
          headPosition = Offset(arrowHeight, 0);
          headOffsetToDelta = (Offset o) => o.dx;
          tailPosition = Offset(size.width, size.height / 2 + tailWidth / 2);
          tailOffsetToDelta = (Offset o) => 2 * o.dy;
        }
        break;
      case ShapeSide.right: //right
        {
          headPosition = Offset(size.width - arrowHeight, 0);
          headOffsetToDelta = (Offset o) => -o.dx;
          tailPosition = Offset(0, size.height / 2 + tailWidth / 2);
          tailOffsetToDelta = (Offset o) => 2 * o.dy;
        }
        break;
    }

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: headPosition,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            currentShape = shape.copyWith(
                arrowHeight: updateLength(shape.arrowHeight, arrowHeight,
                    constraintSize:
                        shape.side.isHorizontal ? size.width : size.height,
                    offset: details.delta,
                    offsetToDelta: headOffsetToDelta));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: tailPosition,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            currentShape = shape.copyWith(
                tailWidth: updateLength(shape.tailWidth, tailWidth,
                    constraintSize:
                        shape.side.isHorizontal ? size.height : size.width,
                    offset: details.delta,
                    offsetToDelta: tailOffsetToDelta));
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
          radiusOffset = Offset(size.width - borderRadius, size.height);
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

  List<Widget> buildRectangleEditingWidgets(RectangleShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    BorderRadius borderRadius = shape.borderRadius.toBorderRadius(size);

    double topLeftRadius = borderRadius.topLeft.x.clamp(0, size.width);
    double topRightRadius = borderRadius.topRight.x.clamp(0, size.width);

    double bottomLeftRadius =
    borderRadius.bottomLeft.x.clamp(0, size.width);
    double bottomRightRadius =
    borderRadius.bottomRight.x.clamp(0, size.width);


    double leftTopRadius = borderRadius.topLeft.y.clamp(0, size.height);
    double leftBottomRadius = borderRadius.bottomLeft.y.clamp(0, size.height);


    double rightTopRadius = borderRadius.topRight.y.clamp(0, size.height);
    double rightBottomRadius = borderRadius.bottomRight.y.clamp(0, size.height);


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
      color: Colors.green,
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
        color: Colors.blue,
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
        color: Colors.red,
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
        color: Colors.green,
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
        color: Colors.blue,
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
        color: Colors.red,
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
    inset = inset.clamp(0.0, radius*0.99);
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

    double omega = -pi/2;
    double r = radius - cornerRadius / sin(beta);
    Offset center =
    Offset((r * cos(omega)) + centerX, (r * sin(omega)) + centerY);
    double sweepAngle = 2 * (pi / 2 - beta);
    Offset start = arcToCubicBezier(
        Rect.fromCircle(center: center, radius: cornerRadius),
        omega - sweepAngle / 2,
        sweepAngle).first;

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: start
            .scale(size.width / width, size.height / height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            currentShape = shape.copyWith(
                cornerRadius: updateLength(shape.cornerRadius, cornerRadius,
                    constraintSize: scale,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dy / cos(beta)*tan(beta)));
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
                    constraintSize: radius,
                    offset: details.delta,
                    offsetToDelta: (o) => (-o.dx / cos(-pi / 2 + alpha))));
          });
        }));

    omega=-pi/2-alpha;
    sweepAngle = pi - 2 * gamma;

    if (gamma <= pi / 2) {
      r = radius - inset + insetRadius / sin(gamma);
      Offset center =
      Offset((r * cos(omega)) + centerX, (r * sin(omega)) + centerY);
      Offset start = arcToCubicBezier(
          Rect.fromCircle(center: center, radius: insetRadius),
          omega + sweepAngle / 2 + pi,
          -sweepAngle).first;
      nodeControls.add(dynamicShapeEditingDragWidget(
          position: start
              .scale(size.width / width, size.height / height),
          onDragUpdate: (DragUpdateDetails details) {
            setState(() {
              currentShape = shape.copyWith(
                  insetRadius: updateLength(shape.insetRadius, insetRadius,
                      constraintSize: scale,
                      offset: details.delta,
                      offsetToDelta: (o) =>
                          (o.dx*cos(omega-gamma)+o.dy*sin(omega-gamma))*tan(gamma)));
            });
          }));
    } else {
      sweepAngle = -sweepAngle;
      r = radius - inset - insetRadius / sin(gamma);
      Offset center =
      Offset((r * cos(omega)) + centerX, (r * sin(omega)) + centerY);
      Offset start = arcToCubicBezier(
          Rect.fromCircle(center: center, radius: insetRadius),
          omega - sweepAngle / 2,
          sweepAngle).first;
      nodeControls.add(dynamicShapeEditingDragWidget(
          position: start
              .scale(size.width / width, size.height / height),
          onDragUpdate: (DragUpdateDetails details) {
            setState(() {
              currentShape = shape.copyWith(
                  insetRadius: updateLength(shape.insetRadius, insetRadius,
                      constraintSize: scale,
                      offset: details.delta,
                      offsetToDelta: (o) => -(o.dx*cos(omega-gamma)+o.dy*sin(omega-gamma))*tan(gamma)));
            });
          }));
    }

    return nodeControls;
  }

  List<Widget> buildTrapezoidEditingWidgets(TrapezoidShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    final width = size.width;
    final height = size.height;

    double inset;
    if (shape.side.isHorizontal) {
      inset =
          shape.inset.toPX(constraintSize: size.width).clamp(0, size.width / 2);
    } else {
      inset = shape.inset
          .toPX(constraintSize: size.height)
          .clamp(0, size.height / 2);
    }

    Offset position;
    Function onDragUpdate;
    switch (shape.side) {
      case ShapeSide.top:
        position = Offset(inset, 0);
        onDragUpdate = (Offset o) => o.dx;
        break;
      case ShapeSide.bottom:
        position = Offset(inset, height);
        onDragUpdate = (Offset o) => o.dx;
        break;
      case ShapeSide.left:
        position = Offset(0, inset);
        onDragUpdate = (Offset o) => o.dy;
        break;
      case ShapeSide.right:
        position = Offset(width, inset);
        onDragUpdate = (Offset o) => o.dy;
        break;
    }

    nodeControls.add(dynamicShapeEditingDragWidget(
      position: position,
      onDragUpdate: (DragUpdateDetails details) {
        setState(() {
          currentShape = shape.copyWith(
              inset: updateLength(shape.inset, inset,
                  constraintSize:
                      shape.side.isHorizontal ? size.width : size.height,
                  offset: details.delta,
                  offsetToDelta: onDragUpdate));
        });
      },
    ));

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

  Widget buildRowWithHeaderText({String headerText, Widget actionWidget}) {
    return Container(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 80,
            child: Text(
              headerText,
              maxLines: 2,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                  fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          actionWidget
        ],
      ),
    );
  }

  List<Widget> buildPathEditingPanelWidget(PathShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    DynamicPath path = shape.path;
    path.resize(shapeSize);

    if (selectedNodeIndex != null) {
      rst.add(buildRowWithHeaderText(
          headerText: "Position",
          actionWidget: OffsetPicker(
            position: path.nodes[selectedNodeIndex].position,
            onPositionChanged: (Offset newPos) {
              setState(() {
                print("new pos: " + newPos.toString());
                path.moveNodeTo(selectedNodeIndex, newPos);
                currentShape = shape.copyWith(path: path);
              });
            },
            constraintSize: shapeSize,
          )));

      rst.add(buildRowWithHeaderText(
          headerText: "Previous Control",
          actionWidget: path.nodes[selectedNodeIndex].prev != null
              ? OffsetPicker(
                  position: path.nodes[selectedNodeIndex].prev,
                  onPositionChanged: (Offset newPos) {
                    setState(() {
                      path.moveNodeControlTo(selectedNodeIndex, true, newPos);
                      currentShape = shape.copyWith(path: path);
                    });
                  },
                  constraintSize: shapeSize,
                )
              : Container(
                  padding: EdgeInsets.only(right: 5),
                  child: Text("Not in use"))));

      rst.add(buildRowWithHeaderText(
          headerText: "Next Control",
          actionWidget: path.nodes[selectedNodeIndex].next != null
              ? OffsetPicker(
                  position: path.nodes[selectedNodeIndex].next,
                  onPositionChanged: (Offset newPos) {
                    setState(() {
                      path.moveNodeControlTo(selectedNodeIndex, false, newPos);
                      currentShape = shape.copyWith(path: path);
                    });
                  },
                  constraintSize: shapeSize,
                )
              : Container(
                  padding: EdgeInsets.only(right: 5),
                  child: Text("Not in use"))));

      rst.add(buildRowWithHeaderText(
          headerText: "Delete Node",
          actionWidget: Container(
            padding: EdgeInsets.only(right: 5),
            child: IconButton(
                icon: Icon(
                  Icons.delete,
                  size: 28,
                ),
                onPressed: () {
                  setState(() {
                    path.nodes.removeAt(selectedNodeIndex);
                    currentShape = shape.copyWith(path: path);
                    selectedNodeIndex = null;
                  });
                }),
          )));
    }

    return rst;
  }

  List<Widget> buildArcEditingPanelWidget(ArcShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(buildRowWithHeaderText(
        headerText: "Arc Side",
        actionWidget: DropdownButton<ShapeSide>(
            value: shape.side,
            onChanged: (ShapeSide newSide) {
              setState(() {
                currentShape = shape.copyWith(side: newSide);
              });
            },
            items: ShapeSide.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.toJson())))
                .toList())));

    rst.add(buildRowWithHeaderText(
        headerText: "Arc outward",
        actionWidget: Switch(
            activeColor: Colors.black87,
            value: shape.isOutward,
            onChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(isOutward: value);
              });
            })));

    rst.add(buildRowWithHeaderText(
      headerText: "Arc Height",
      actionWidget: Expanded(
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
    ));

    return rst;
  }

  List<Widget> buildArrowEditingPanelWidget(ArrowShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(buildRowWithHeaderText(
        headerText: "Arrow Side",
        actionWidget: DropdownButton<ShapeSide>(
            value: shape.side,
            onChanged: (ShapeSide newSide) {
              setState(() {
                currentShape = shape.copyWith(side: newSide);
              });
            },
            items: ShapeSide.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.toJson())))
                .toList())));

    rst.add(buildRowWithHeaderText(
      headerText: "Head Height",
      actionWidget: Expanded(
        child: LengthSlider(
          sliderValue: shape.arrowHeight,
          valueChanged: (value) {
            setState(() {
              currentShape = shape.copyWith(arrowHeight: value);
            });
          },
          constraintSize: shape.side.isHorizontal ? size.height : size.width,
          allowedUnits: ["px", "%"],
        ),
      ),
    ));

    rst.add(buildRowWithHeaderText(
      headerText: "Tail Width",
      actionWidget: Expanded(
        child: LengthSlider(
          sliderValue: shape.tailWidth,
          valueChanged: (value) {
            setState(() {
              currentShape = shape.copyWith(tailWidth: value);
            });
          },
          constraintSize: shape.side.isHorizontal ? size.width : size.height,
          allowedUnits: ["px", "%"],
        ),
      ),
    ));

    return rst;
  }

  List<Widget> buildBubbleEditingPanelWidget(BubbleShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(buildRowWithHeaderText(
        headerText: "Arrow Corner",
        actionWidget: DropdownButton<ShapeCorner>(
            value: shape.corner,
            onChanged: (ShapeCorner value) {
              setState(() {
                currentShape = shape.copyWith(corner: value);
              });
            },
            items: ShapeCorner.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.toJson())))
                .toList())));

    rst.add(buildRowWithHeaderText(
        headerText: "Arrow Center",
        actionWidget: Expanded(
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
        )));

    rst.add(buildRowWithHeaderText(
      headerText: "Arrow Head",
      actionWidget: Expanded(
        child: LengthSlider(
          sliderValue: shape.arrowHeadPosition,
          valueChanged: (value) {
            setState(() {
              currentShape = shape.copyWith(arrowHeadPosition: value);
            });
          },
          constraintSize: shape.corner.isHorizontal ? size.width : size.height,
          allowedUnits: ["px", "%"],
        ),
      ),
    ));

    rst.add(buildRowWithHeaderText(
        headerText: "Arrow Height",
        actionWidget: Expanded(
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
        )));

    rst.add(buildRowWithHeaderText(
      headerText: "Arrow Width",
      actionWidget: Expanded(
        child: LengthSlider(
          sliderValue: shape.arrowWidth,
          valueChanged: (value) {
            setState(() {
              currentShape = shape.copyWith(arrowWidth: value);
            });
          },
          constraintSize: shape.corner.isHorizontal ? size.width : size.height,
          allowedUnits: ["px", "%"],
        ),
      ),
    ));

    rst.add(buildRowWithHeaderText(
      headerText: "Border Radius",
      actionWidget: Expanded(
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
    ));

    return rst;
  }

  List<Widget> buildCircleEditingPanelWidget(CircleShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(buildRowWithHeaderText(
        headerText: "Start Angle",
        actionWidget: Slider(
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
        )));

    rst.add(buildRowWithHeaderText(
        headerText: "Sweep Angle",
        actionWidget: Slider(
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
        )));

    return rst;
  }

  List<Widget> buildPolygonEditingPanelWidget(PolygonShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(buildRowWithHeaderText(
        headerText: "Sides",
        actionWidget: DropdownButton<int>(
            value: shape.sides,
            onChanged: (int newSide) {
              setState(() {
                currentShape = shape.copyWith(sides: newSide);
              });
            },
            items: [3, 5, 6, 7, 8, 10, 12, 16, 20, 24]
                .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e.toString())))
                .toList())));

    rst.add(buildRowWithHeaderText(
        headerText: "Corner Style",
        actionWidget: DropdownButton<CornerStyle>(
            value: shape.cornerStyle,
            onChanged: (CornerStyle newSide) {
              setState(() {
                currentShape = shape.copyWith(cornerStyle: newSide);
              });
            },
            items: [CornerStyle.rounded, CornerStyle.straight, CornerStyle.cutout]
                .map((e) =>
                DropdownMenuItem(value: e, child: Text(e.toJson())))
                .toList())));

    rst.add(buildRowWithHeaderText(
      headerText: "Corner Radius",
      actionWidget: Expanded(
        child: LengthSlider(
          sliderValue: shape.cornerRadius,
          valueChanged: (value) {
            setState(() {
              currentShape = shape.copyWith(cornerRadius: value);
            });
          },
          constraintSize: min(size.width, size.height),
          allowedUnits: ["px", "%"],
        ),
      ),
    ));

    return rst;
  }

  List<Widget> buildRectangleEditingPanelWidget(RectangleShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(Column(children: [Align(
      alignment: Alignment.centerLeft,
      child: Text("Top Left:",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
    ),
      buildRowWithHeaderText(headerText: "Style",
          actionWidget: DropdownButton<CornerStyle>(
              value: shape.topLeft,
              onChanged: (CornerStyle newSide) {
                setState(() {
                  currentShape = shape.copyWith(topLeft: newSide);
                });
              },
              items: CornerStyle.values
                  .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e.toJson())))
                  .toList())),
      buildRowWithHeaderText(
        headerText: "X",
        actionWidget: Expanded(
          child: LengthSlider(
            sliderValue: shape.borderRadius.topLeft.x,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(
                    borderRadius: shape.borderRadius.copyWith(
                        topLeft: shape.borderRadius.topLeft.copyWith(x: value)));
              });
            },
            constraintSize: size.width,
            allowedUnits: ["px", "%"],
          ),
        ),
      ),
      buildRowWithHeaderText(
        headerText: "Y",
        actionWidget: Expanded(
          child: LengthSlider(
            sliderValue: shape.borderRadius.topLeft.y,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(
                    borderRadius: shape.borderRadius.copyWith(
                        topLeft: shape.borderRadius.topLeft.copyWith(y: value)));
              });
            },
            constraintSize: size.height,
            allowedUnits: ["px", "%"],
          ),
        ),
      )
    ],));

    rst.add(Column(children: [Align(
      alignment: Alignment.centerLeft,
      child: Text("Top Right:",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
    ),
      buildRowWithHeaderText(headerText: "Style",
          actionWidget: DropdownButton<CornerStyle>(
              value: shape.topRight,
              onChanged: (CornerStyle newSide) {
                setState(() {
                  currentShape = shape.copyWith(topRight: newSide);
                });
              },
              items: CornerStyle.values
                  .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e.toJson())))
                  .toList())),
      buildRowWithHeaderText(
        headerText: "X",
        actionWidget: Expanded(
          child: LengthSlider(
            sliderColor: Colors.green,
            sliderValue: shape.borderRadius.topRight.x,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(
                    borderRadius: shape.borderRadius.copyWith(
                        topRight: shape.borderRadius.topRight.copyWith(x: value)));
              });
            },
            constraintSize: size.width,
            allowedUnits: ["px", "%"],
          ),
        ),
      ),
      buildRowWithHeaderText(
        headerText: "Y",
        actionWidget: Expanded(
          child: LengthSlider(
            sliderColor: Colors.green,
            sliderValue: shape.borderRadius.topRight.y,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(
                    borderRadius: shape.borderRadius.copyWith(
                        topRight: shape.borderRadius.topRight.copyWith(y: value)));
              });
            },
            constraintSize: size.height,
            allowedUnits: ["px", "%"],
          ),
        ),
      )
    ],));

    rst.add(Column(children: [Align(
      alignment: Alignment.centerLeft,
      child: Text("Bottom Left:",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
    ),
      buildRowWithHeaderText(headerText: "Style",
          actionWidget: DropdownButton<CornerStyle>(
              value: shape.bottomLeft,
              onChanged: (CornerStyle newSide) {
                setState(() {
                  currentShape = shape.copyWith(bottomLeft: newSide);
                });
              },
              items: CornerStyle.values
                  .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e.toJson())))
                  .toList())),
      buildRowWithHeaderText(
        headerText: "X",
        actionWidget: Expanded(
          child: LengthSlider(
            sliderColor: Colors.blue,
            sliderValue: shape.borderRadius.bottomLeft.x,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(
                    borderRadius: shape.borderRadius.copyWith(
                        bottomLeft: shape.borderRadius.bottomLeft.copyWith(x: value)));
              });
            },
            constraintSize: size.width,
            allowedUnits: ["px", "%"],
          ),
        ),
      ),
      buildRowWithHeaderText(
        headerText: "Y",
        actionWidget: Expanded(
          child: LengthSlider(
            sliderColor: Colors.blue,
            sliderValue: shape.borderRadius.bottomLeft.y,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(
                    borderRadius: shape.borderRadius.copyWith(
                        bottomLeft: shape.borderRadius.bottomLeft.copyWith(y: value)));
              });
            },
            constraintSize: size.height,
            allowedUnits: ["px", "%"],
          ),
        ),
      )
    ],));

    rst.add(Column(children: [Align(
      alignment: Alignment.centerLeft,
      child: Text("Bottom Right:",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
    ),
      buildRowWithHeaderText(headerText: "Style",
          actionWidget: DropdownButton<CornerStyle>(
              value: shape.bottomRight,
              onChanged: (CornerStyle newSide) {
                setState(() {
                  currentShape = shape.copyWith(bottomRight: newSide);
                });
              },
              items: CornerStyle.values
                  .map((e) =>
                  DropdownMenuItem(value: e, child: Text(e.toJson())))
                  .toList())),
      buildRowWithHeaderText(
        headerText: "X",
        actionWidget: Expanded(
          child: LengthSlider(
            sliderColor: Colors.red,
            sliderValue: shape.borderRadius.bottomRight.x,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(
                    borderRadius: shape.borderRadius.copyWith(
                        bottomRight: shape.borderRadius.bottomRight.copyWith(x: value)));
              });
            },
            constraintSize: size.width,
            allowedUnits: ["px", "%"],
          ),
        ),
      ),
      buildRowWithHeaderText(
        headerText: "Y",
        actionWidget: Expanded(
          child: LengthSlider(
            sliderColor: Colors.red,
            sliderValue: shape.borderRadius.bottomRight.y,
            valueChanged: (value) {
              setState(() {
                currentShape = shape.copyWith(
                    borderRadius: shape.borderRadius.copyWith(
                        bottomRight: shape.borderRadius.bottomRight.copyWith(y: value)));
              });
            },
            constraintSize: size.height,
            allowedUnits: ["px", "%"],
          ),
        ),
      )
    ],));

    return rst;
  }

  List<Widget> buildStarEditingPanelWidget(StarShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(buildRowWithHeaderText(
        headerText: "Corners",
        actionWidget: DropdownButton<int>(
            value: shape.corners,
            onChanged: (int newSide) {
              setState(() {
                currentShape = shape.copyWith(corners: newSide);
              });
            },
            items: [3, 4, 5, 6, 7, 8, 10, 12, 16, 20, 24]
                .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e.toString())))
                .toList())));

    rst.add(buildRowWithHeaderText(
        headerText: "Corner Style",
        actionWidget: DropdownButton<CornerStyle>(
            value: shape.cornerStyle,
            onChanged: (CornerStyle newSide) {
              setState(() {
                currentShape = shape.copyWith(cornerStyle: newSide);
              });
            },
            items: [CornerStyle.rounded, CornerStyle.straight, CornerStyle.cutout]
                .map((e) =>
                DropdownMenuItem(value: e, child: Text(e.toJson())))
                .toList())));

    rst.add(buildRowWithHeaderText(
      headerText: "Corner Radius",
      actionWidget: Expanded(
        child: LengthSlider(
          sliderValue: shape.cornerRadius,
          valueChanged: (value) {
            setState(() {
              currentShape = shape.copyWith(cornerRadius: value);
            });
          },
          constraintSize: min(size.width, size.height),
          allowedUnits: ["px", "%"],
        ),
      ),
    ));

    rst.add(buildRowWithHeaderText(
      headerText: "Inset",
      actionWidget: Expanded(
        child: LengthSlider(
          sliderValue: shape.inset,
          valueChanged: (value) {
            setState(() {
              currentShape = shape.copyWith(inset: value);
            });
          },
          constraintSize: min(size.width, size.height),
          allowedUnits: ["px", "%"],
        ),
      ),
    ));

    rst.add(buildRowWithHeaderText(
        headerText: "Inset Style",
        actionWidget: DropdownButton<CornerStyle>(
            value: shape.insetStyle,
            onChanged: (CornerStyle newSide) {
              setState(() {
                currentShape = shape.copyWith(insetStyle: newSide);
              });
            },
            items: [CornerStyle.rounded, CornerStyle.straight, CornerStyle.cutout]
                .map((e) =>
                DropdownMenuItem(value: e, child: Text(e.toJson())))
                .toList())));

    rst.add(buildRowWithHeaderText(
      headerText: "Inset Radius",
      actionWidget: Expanded(
        child: LengthSlider(
          sliderValue: shape.insetRadius,
          valueChanged: (value) {
            setState(() {
              currentShape = shape.copyWith(insetRadius: value);
            });
          },
          constraintSize: min(size.width, size.height),
          allowedUnits: ["px", "%"],
        ),
      ),
    ));

    return rst;
  }

  List<Widget> buildTrapezoidEditingPanelWidget(TrapezoidShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(buildRowWithHeaderText(
        headerText: "Point 1",
        actionWidget: DropdownButton<ShapeSide>(
            value: shape.side,
            onChanged: (ShapeSide newSide) {
              setState(() {
                currentShape = shape.copyWith(side: newSide);
              });
            },
            items: ShapeSide.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.toJson())))
                .toList())));

    rst.add(buildRowWithHeaderText(
      headerText: "Inset",
      actionWidget: Expanded(
        child: LengthSlider(
          sliderValue: shape.inset,
          valueChanged: (value) {
            setState(() {
              currentShape = shape.copyWith(inset: value);
            });
          },
          constraintSize: shape.side.isHorizontal ? size.width : size.height,
          allowedUnits: ["px", "%"],
        ),
      ),
    ));

    return rst;
  }

  List<Widget> buildTriangleEditingPanelWidget(TriangleShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(buildRowWithHeaderText(
      headerText: "Point 1",
      actionWidget: Container(
        height: 50,
        child: Row(
          children: [
            Text("X  "),
            FixedUnitValuePicker(
              value: shape.point1.dx.value,
              onValueChanged: (double value) {
                currentShape = shape.copyWith(
                    point1: shape.point1.copyWith(dx: value.toPercentLength));
              },
              unit: "%",
            ),
            Container(
              width: 10,
            ),
            Text("Y  "),
            FixedUnitValuePicker(
              value: shape.point1.dy.value,
              onValueChanged: (double value) {
                currentShape = shape.copyWith(
                    point1: shape.point1.copyWith(dy: value.toPercentLength));
              },
              unit: "%",
            ),
          ],
        ),
      ),
    ));

    rst.add(buildRowWithHeaderText(
      headerText: "Point 2",
      actionWidget: Container(
        height: 50,
        child: Row(
          children: [
            Text("X  "),
            FixedUnitValuePicker(
              value: shape.point2.dx.value,
              onValueChanged: (double value) {
                currentShape = shape.copyWith(
                    point2: shape.point1.copyWith(dx: value.toPercentLength));
              },
              unit: "%",
            ),
            Container(
              width: 10,
            ),
            Text("Y  "),
            FixedUnitValuePicker(
              value: shape.point2.dy.value,
              onValueChanged: (double value) {
                currentShape = shape.copyWith(
                    point2: shape.point1.copyWith(dy: value.toPercentLength));
              },
              unit: "%",
            ),
          ],
        ),
      ),
    ));

    rst.add(buildRowWithHeaderText(
      headerText: "Point 3",
      actionWidget: Container(
        height: 50,
        child: Row(
          children: [
            Text("X  "),
            FixedUnitValuePicker(
              value: shape.point3.dx.value,
              onValueChanged: (double value) {
                currentShape = shape.copyWith(
                    point1: shape.point3.copyWith(dx: value.toPercentLength));
              },
              unit: "%",
            ),
            Container(
              width: 10,
            ),
            Text("Y  "),
            FixedUnitValuePicker(
              value: shape.point3.dy.value,
              onValueChanged: (double value) {
                currentShape = shape.copyWith(
                    point1: shape.point3.copyWith(dy: value.toPercentLength));
              },
              unit: "%",
            ),
          ],
        ),
      ),
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
