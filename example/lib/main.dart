import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:morphable_shape/MorphableShapeBorder.dart';
import 'package:length_unit/length_unit.dart';
import 'dart:math';

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

  Shape startShape;
  Shape endShape;

  int selectedNodeIndex;
  double nodeSize = 8;
  Size shapeSize = Size(400, 400);
  bool isEditingPath = false;

  AnimationController controller;
  Animation animation;

  static int gridCount = 30;

  @override
  void initState() {
    super.initState();
    //startShape = StarShape(cornerRadius: Length(250), corners: 5);
    startShape=BubbleShape();

    DynamicPath path = StarShape(cornerRadius: Length(0), corners: 4)
        .generateDynamicPath(
            Rect.fromLTRB(0, 0, shapeSize.width, shapeSize.height));
    endShape = PathShape(path: path);

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

    MorphableShapeBorder startBorder;
    MorphableShapeBorder endBorder;

    startBorder = MorphableShapeBorder(shape: startShape, borderColor: Colors.redAccent, borderWidth: 10);
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
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.blueAccent)),
          width: shapeSize.width,
          height: shapeSize.height,
        ),
      ),
    ];

    if (isEditingPath) {
      if (startShape is PathShape) {
        stackedComponents.addAll(buildPathEdittingWidgets(startShape));
      }
      if (startShape is ArcShape) {
        stackedComponents.addAll(buildArcEditingWidgets(startShape));
      }
      if (startShape is BubbleShape) {
        stackedComponents.addAll(buildBubbleEditingWidgets(startShape));
      }
      if (startShape is CutCornerShape) {
        stackedComponents.addAll(buildCutCornerEditingWidgets(startShape));
      }
      if (startShape is PolygonShape) {
        stackedComponents.addAll(buildPolygonEditingWidgets(startShape));
      }
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

  Widget addControlPointWidget(DynamicPath path, int index) {
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
            startShape=PathShape(path: path);
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

  List<Widget> buildPathEdittingWidgets(PathShape shape) {
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
                      startShape=shape.copyWith(
                        path: path
                      );
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
              startShape=shape.copyWith(
                  path: path
              );
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
              startShape=shape.copyWith(
                  path: path
              );
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
        onPanUpdate: onDragUpdate,
        child: Container(
          width: 2 * nodeSize,
          height: 2 * nodeSize,
          decoration: BoxDecoration(
              color: Colors.amber, border: Border.all(color: Colors.black)),
        ),
      ),
    );
  }

  Length updateLength(Length length,
      {double constraintSize,
      double minimumSize = 0.1,
      double maximumSize = double.infinity,
      Offset delta,
      double Function(Offset) offsetToDelta}) {
    double newValue =
        length.toPX(constraintSize: constraintSize) + offsetToDelta(delta);
    return length.copyWith(
        value: Length.newValue(
            newValue.clamp(minimumSize, maximumSize), length.unit,
            constraintSize: constraintSize));
  }

  List<Widget> buildArcEditingWidgets(ArcShape shape) {
    List<Widget> nodeControls=[];

    Size size=shapeSize;

    double maximumSize = min(size.height, size.height) / 2;

    switch (shape.side) {
      case ShapeSide.top:
        nodeControls.add(dynamicShapeEditingDragWidget(
            position: Offset(size.width / 2,
                shape.arcHeight.toPX(constraintSize: size.height)),
            onDragUpdate: (DragUpdateDetails details) {
              setState(() {
                startShape = shape.copyWith(
                  arcHeight: updateLength(shape.arcHeight,
                      constraintSize: size.height,
                      maximumSize: maximumSize,
                      delta: details.delta,
                      offsetToDelta: (o) => o.dy)
                );
              });
            }));
        break;
      case ShapeSide.bottom:
        nodeControls.add(dynamicShapeEditingDragWidget(
            position: Offset(
                size.width / 2,
                size.height -
                    shape.arcHeight.toPX(constraintSize: size.height)),
            onDragUpdate: (DragUpdateDetails details) {
              setState(() {
                startShape = shape.copyWith(
                  arcHeight: updateLength(shape.arcHeight,
                      constraintSize: size.height,
                      maximumSize: maximumSize,
                      delta: details.delta,
                      offsetToDelta: (o) => -o.dy)
                );
              });
            }));
        break;
      case ShapeSide.left:
        nodeControls.add(dynamicShapeEditingDragWidget(
            position: Offset(
                shape.arcHeight.toPX(constraintSize: size.width),
                size.height / 2),
            onDragUpdate: (DragUpdateDetails details) {
              setState(() {
                startShape=shape.copyWith(arcHeight: updateLength(shape.arcHeight,
                    constraintSize: size.width,
                    maximumSize: maximumSize,
                    delta: details.delta,
                    offsetToDelta: (o) => o.dx));
              });
            }));
        break;
      case ShapeSide.right: //right
        nodeControls.add(dynamicShapeEditingDragWidget(
            position: Offset(
                size.width -
                    shape.arcHeight.toPX(constraintSize: size.width),
                size.height / 2),
            onDragUpdate: (DragUpdateDetails details) {
              setState(() {
                startShape= shape.copyWith(arcHeight: updateLength(shape.arcHeight,
                    constraintSize: size.width,
                    maximumSize: maximumSize,
                    delta: details.delta,
                    offsetToDelta: (o) => -o.dx)
                );
              });
            }));
        break;
    }

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

    if (shape.corner.isHorizontalRight) {
      arrowCenterPosition = size.width - arrowCenterPosition;
      arrowHeadPosition = size.width - arrowHeadPosition;
    }
    if (shape.corner.isVerticalBottom) {
      arrowCenterPosition = size.height - arrowCenterPosition;
      arrowHeadPosition = size.height - arrowHeadPosition;
    }

    final double left = spacingLeft ;
    final double top = spacingTop ;
    final double right = size.width - spacingRight;
    final double bottom = size.height - spacingBottom;

    double radiusBound = 0;

    if (shape.corner.isHorizontal) {
      arrowCenterPosition = arrowCenterPosition.clamp(0, size.width);
      arrowHeadPosition = arrowHeadPosition.clamp(0, size.width);
      arrowWidth =
          arrowWidth.clamp(0, 2 * min(arrowCenterPosition, size.width - arrowCenterPosition));
      radiusBound = min(
          min(right - arrowCenterPosition - arrowWidth / 2,
              arrowCenterPosition - arrowWidth / 2 - left),
          (bottom - top) / 2);
      borderRadius =
          borderRadius.clamp(0.0, radiusBound >= 0 ? radiusBound : 0);
    } else {
      arrowCenterPosition = arrowCenterPosition.clamp(0, size.height);
      arrowHeadPosition = arrowHeadPosition.clamp(0, size.height);
      arrowWidth =
          arrowWidth.clamp(0, 2 * min(arrowCenterPosition, size.height - arrowCenterPosition));
      radiusBound = min(
          min(bottom - arrowCenterPosition - arrowWidth / 2,
              arrowCenterPosition - arrowWidth / 2 - top),
          (right - left) / 2);
      borderRadius = borderRadius.clamp(
        0.0,
        radiusBound >= 0 ? radiusBound : 0,
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
          arrowWidthOffset =
              Offset((arrowCenterPosition - arrowWidth / 2).clamp(0.0, size.width), top);
          arrowHeadDragUpdate = (Offset o) => o.dx;
          arrowWidthDragUpdate = (Offset o) => -o.dx;
          arrowCenterDragUpdateHorizontal = (Offset o) => o.dx;
          arrowCenterDragUpdateVertical = (Offset o) => o.dy;
          radiusOffset =
              Offset(size.width - borderRadius, size.height - borderRadius);
          radiusDragUpdate = (Offset o) => -o.dx;
        }
        break;
      case ShapeCorner.topRight:
        {
          arrowHeadOffset = Offset(arrowHeadPosition, 0);
          arrowCenterOffset = Offset(arrowCenterPosition, top);
          arrowWidthOffset =
              Offset((arrowCenterPosition - arrowWidth / 2).clamp(0.0, size.width), top);
          arrowHeadDragUpdate = (Offset o) => -o.dx;
          arrowWidthDragUpdate = (Offset o) => -o.dx;
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
          arrowWidthOffset =
              Offset((arrowCenterPosition - arrowWidth / 2).clamp(0.0, size.width), bottom);
          arrowHeadDragUpdate = (Offset o) => o.dx;
          arrowWidthDragUpdate = (Offset o) => -o.dx;
          arrowCenterDragUpdateHorizontal = (Offset o) => o.dx;
          arrowCenterDragUpdateVertical = (Offset o) => -o.dy;

          radiusOffset = Offset(borderRadius, 0);
          radiusDragUpdate = (Offset o) => o.dx;
        }
        break;
      case ShapeCorner.bottomRight:
        {
          arrowHeadOffset = Offset(arrowHeadPosition, size.height);
          arrowCenterOffset = Offset(arrowCenterPosition, bottom);
          arrowWidthOffset =
              Offset((arrowCenterPosition - arrowWidth / 2).clamp(0.0, size.width), bottom);
          arrowHeadDragUpdate = (Offset o) => -o.dx;
          arrowWidthDragUpdate = (Offset o) => -o.dx;
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
          arrowWidthOffset =
              Offset(left, (arrowCenterPosition - arrowWidth / 2).clamp(0.0, size.height));
          arrowHeadDragUpdate = (Offset o) => o.dy;
          arrowWidthDragUpdate = (Offset o) => -o.dy;
          arrowCenterDragUpdateHorizontal = (Offset o) => o.dy;
          arrowCenterDragUpdateVertical = (Offset o) => o.dx;

          radiusOffset = Offset(size.width, borderRadius);
          radiusDragUpdate = (Offset o) => o.dy;
        }
        break;
      case ShapeCorner.leftBottom:
        {
          arrowHeadOffset = Offset(0, arrowHeadPosition);
          arrowCenterOffset = Offset(left, arrowCenterPosition);
          arrowWidthOffset =
              Offset(left, (arrowCenterPosition - arrowWidth / 2).clamp(0.0, size.height));
          arrowHeadDragUpdate = (Offset o) => -o.dy;
          arrowWidthDragUpdate = (Offset o) => -o.dy;
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
          arrowWidthOffset =
              Offset(right, (arrowCenterPosition - arrowWidth / 2).clamp(0.0, size.height));
          arrowHeadDragUpdate = (Offset o) => o.dy;
          arrowWidthDragUpdate = (Offset o) => -o.dy;
          arrowCenterDragUpdateHorizontal = (Offset o) => o.dy;
          arrowCenterDragUpdateVertical = (Offset o) => -o.dx;

          radiusOffset = Offset(0, borderRadius);
          radiusDragUpdate = (Offset o) => o.dy;
        }
        break;
      case ShapeCorner.rightBottom:
        {
          arrowHeadOffset = Offset(size.width, arrowHeadPosition);
          arrowCenterOffset = Offset(right, arrowCenterPosition);
          arrowWidthOffset =
              Offset(right, (arrowCenterPosition - arrowWidth / 2).clamp(0.0, size.height));
          arrowHeadDragUpdate = (Offset o) => -o.dy;
          arrowWidthDragUpdate = (Offset o) => -o.dy;
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
            startShape=shape.copyWith(
              arrowHeight: updateLength(shape.arrowHeight,
                  constraintSize: size.height,
                  maximumSize: min(size.width, size.height),
                  delta: details.delta,
                  offsetToDelta: arrowCenterDragUpdateVertical),
              arrowCenterPosition: updateLength(shape.arrowCenterPosition,
                  constraintSize: size.height,
                  maximumSize: size.width,
                  delta: details.delta,
                  offsetToDelta: arrowCenterDragUpdateHorizontal)
            );
          });
        }));
    nodeControls.add(dynamicShapeEditingDragWidget(
        position: arrowWidthOffset,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            startShape=shape.copyWith(arrowWidth: updateLength(shape.arrowWidth,
                constraintSize: size.width,
                maximumSize: size.width,
                delta: details.delta,
                offsetToDelta: arrowWidthDragUpdate));
          });
        }));
    nodeControls.add(dynamicShapeEditingDragWidget(
        position: arrowHeadOffset,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            startShape=shape.copyWith(
              arrowHeadPosition: updateLength(shape.arrowHeadPosition,
                  constraintSize: size.width,
                  maximumSize: size.width,
                  delta: details.delta,
                  offsetToDelta: arrowHeadDragUpdate)
            );
          });
        }));
    nodeControls.add(dynamicShapeEditingDragWidget(
        position: radiusOffset,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            startShape=shape.copyWith(
              borderRadius: updateLength(shape.borderRadius,
                  constraintSize: size.width,
                  maximumSize: radiusBound,
                  delta: details.delta,
                  offsetToDelta: radiusDragUpdate)
            );
          });
        }));

    return nodeControls;
  }

  List<Widget> buildCutCornerEditingWidgets(CutCornerShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    BorderRadius borderRadius=shape.borderRadius.toBorderRadius(size);

    final topLeftRadius = borderRadius.topLeft.x.clamp(0, size.width/2);
    final topRightRadius = borderRadius.topRight.x.clamp(0, size.width/2);
    final bottomLeftRadius = borderRadius.bottomLeft.x.clamp(0, size.width/2);
    final bottomRightRadius = borderRadius.bottomRight.x.clamp(0, size.width/2);

    final leftTopRadius = borderRadius.topLeft.y.clamp(0, size.height/2);
    final rightTopRadius = borderRadius.topRight.y.clamp(0, size.height/2);
    final leftBottomRadius = borderRadius.bottomLeft.y.clamp(0, size.height/2);
    final rightBottomRadius = borderRadius.bottomRight.y.clamp(0, size.height/2);

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(topLeftRadius, 0),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius=shape.borderRadius.topLeft.copyWith(
              x: updateLength(shape.borderRadius.topLeft.x,
                  constraintSize: size.width,
                  maximumSize: size.width,
                  delta: details.delta,
                  offsetToDelta: (o)=>o.dx)
            );

            startShape=shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topLeft: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(size.width-topRightRadius, 0),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius=shape.borderRadius.topRight.copyWith(
                x: updateLength(shape.borderRadius.topRight.x,
                    constraintSize: size.width,
                    maximumSize: size.width,
                    delta: details.delta,
                    offsetToDelta: (o)=>-o.dx)
            );

            startShape=shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topRight: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(bottomLeftRadius, size.height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius=shape.borderRadius.bottomLeft.copyWith(
                x: updateLength(shape.borderRadius.bottomLeft.x,
                    constraintSize: size.width,
                    maximumSize: size.width,
                    delta: details.delta,
                    offsetToDelta: (o)=>o.dx)
            );

            startShape=shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(bottomLeft: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(size.width-bottomRightRadius, size.height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius=shape.borderRadius.bottomRight.copyWith(
                x: updateLength(shape.borderRadius.bottomRight.x,
                    constraintSize: size.width,
                    maximumSize: size.width,
                    delta: details.delta,
                    offsetToDelta: (o)=>-o.dx)
            );

            startShape=shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(bottomRight: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(0, leftTopRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius=shape.borderRadius.topLeft.copyWith(
                y: updateLength(shape.borderRadius.topLeft.y,
                    constraintSize: size.height,
                    maximumSize: size.height,
                    delta: details.delta,
                    offsetToDelta: (o)=>o.dy)
            );

            startShape=shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topLeft: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(size.width, rightTopRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius=shape.borderRadius.topRight.copyWith(
                y: updateLength(shape.borderRadius.topRight.y,
                    constraintSize: size.height,
                    maximumSize: size.height,
                    delta: details.delta,
                    offsetToDelta: (o)=>o.dy)
            );

            startShape=shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topRight: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(0, size.height-leftBottomRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius=shape.borderRadius.bottomLeft.copyWith(
                y: updateLength(shape.borderRadius.bottomLeft.y,
                    constraintSize: size.height,
                    maximumSize: size.height,
                    delta: details.delta,
                    offsetToDelta: (o)=>-o.dy)
            );

            startShape=shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(bottomLeft: newRadius));
          });
        }));

    nodeControls.add(dynamicShapeEditingDragWidget(
        position: Offset(size.width, size.height-rightBottomRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius=shape.borderRadius.bottomRight.copyWith(
                y: updateLength(shape.borderRadius.bottomRight.y,
                    constraintSize: size.height,
                    maximumSize: size.height,
                    delta: details.delta,
                    offsetToDelta: (o)=>-o.dy)
            );

            startShape=shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(bottomRight: newRadius));
          });
        }));

    return nodeControls;
  }

  List<Widget> buildPolygonEditingWidgets(PolygonShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    double scale = min(size.width, size.height);
    double cornerRadius = shape.cornerRadius.toPX(constraintSize: scale);
    int sides=shape.sides;

    final height = scale;
    final width = scale;

    double startAngle=-pi / 2;
    /*
    if (sides.isOdd) {
      startAngle = -pi / 2;
    } else {
      startAngle = -pi / 2 + (pi / sides);
    }

     */

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
        position: Offset(arcCenterX, arcCenterY).scale(size.width/width, size.height/height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            startShape=shape.copyWith(
                cornerRadius: updateLength(shape.cornerRadius,
                    constraintSize: scale,
                    maximumSize: scale,
                    delta: details.delta,
                    offsetToDelta: (o)=>(o.dy)));
          });
        }));


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
