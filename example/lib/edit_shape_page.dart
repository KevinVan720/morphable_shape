import 'dart:math';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:morphable_shape/morphable_shape.dart';
import 'package:morphable_shape/morphable_shape_border.dart';

import 'value_pickers.dart';
import 'morph_shape_page.dart';
import 'how_to_use_text.dart';

class EditShapePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return EditShapePageState();
  }
}

///Widget that allows you to edit a single shape
class EditShapePageState extends State<EditShapePage>
    with SingleTickerProviderStateMixin {
  static double nodeSize = 8;
  static int gridCount = 10;
  static double shapeMinimumSize = 20;

  Shape currentShape;

  ///trying to implement undo/redo, but each drag incurs too many
  ///changes, not making much sense
  //Queue<Map<String, dynamic>> shapeHistory=Queue();
  //Queue<Map<String, dynamic>> redoHistory=Queue();

  Size shapeSize;
  int selectedNodeIndex;
  bool isEditingPath = false;
  bool showGrid = true;
  bool snapToGrid = false;

  TabController _tabController;

  Axis direction;

  Widget control;

  @override
  void initState() {
    super.initState();
    currentShape = RectangleShape();
    _tabController = TabController(vsync: this, length: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

      if (shapeSize == null ||
          shapeSize.width > screenSize.width * 0.8 ||
          shapeSize.height > screenSize.height * 0.8) {
        double length = (min(screenSize.width, screenSize.height) * 0.8)
            .clamp(200.0, 400.0);
        shapeSize = Size(length, length);
      }

      MorphableShapeBorder shapeBorder;

      shapeBorder = MorphableShapeBorder(
        shape: currentShape,
      );

      List<Widget> stackedComponents = [
        Container(
          width: shapeSize.width + nodeSize * 2,
          height: shapeSize.height + nodeSize * 2,
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
        Positioned(
          left: nodeSize,
          top: nodeSize,
          child: Material(
            shape: shapeBorder,
            clipBehavior: Clip.antiAlias,
            animationDuration: Duration.zero,
            child: Container(
              width: shapeSize.width,
              height: shapeSize.height,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ];

      if (isEditingPath) {
        if (currentShape is PathShape && showGrid) {
          stackedComponents.add(Positioned(
              left: nodeSize,
              top: nodeSize,
              child: CustomPaint(
                painter: StackDividerPainter(
                    xDivisions: gridCount,
                    yDivisions: gridCount,
                    showBorder: false),
                child: Container(
                  width: shapeSize.width,
                  height: shapeSize.height,
                ),
              )));
        }
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
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image(
                    width: 30,
                    height: 30,
                    image: AssetImage('assets/images/Icon-192.png')),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Text("Edit Shape"))
              ],
            ),
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
                  icon: Icon(Icons.help),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: SingleChildScrollView(
                            child: Container(
                                width: min(screenSize.width * 0.8, 400),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: howToTextWidgets,
                                )),
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
                          ? (direction == Axis.horizontal
                              ? screenSize.height
                              : 360)
                          : 0,
                      decoration: BoxDecoration(color: Colors.grey, boxShadow: [
                        BoxShadow(
                            offset: Offset(-2, 2),
                            color: Colors.black54,
                            blurRadius: 6,
                            spreadRadius: 0)
                      ]),
                      //padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                      child: DefaultTabController(
                          length: 3,
                          child: Column(
                            children: [
                              Container(
                                color: Colors.black54,
                                child: TabBar(tabs: [
                                  Tab(
                                    //icon: Icon(Icons.directions_bike),
                                    text: "BASIC",
                                  ),
                                  Tab(
                                    //icon: Icon(Icons.remove),
                                    text: "SHAPE",
                                  ),
                                  Tab(
                                    //icon: Icon(Icons.remove),
                                    text: "BORDER",
                                  )
                                ]),
                              ),
                              Expanded(
                                  child: Padding(
                                padding:
                                    EdgeInsets.only(left: 5, right: 5, top: 10),
                                child: TabBarView(
                                  physics: NeverScrollableScrollPhysics(),
                                  children: [
                                    ListView(
                                      children:
                                          buildEditingShapeBasicPanelWidgets(),
                                    ),
                                    ListView(
                                      children: buildEditingShapePanelWidgets(),
                                    ),
                                    ListView(
                                      children:
                                          buildEditingShapeBorderPanelWidgets(),
                                    )
                                  ],
                                ),
                              ))
                            ],
                          )))
                ]),
          ));
    });
  }

  void updateCurrentShape(Shape newShape) {
    currentShape = newShape;
    //shapeHistory.addLast(currentShape.toJson());
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

    if (currentShape is RoundedRectangleShape) {
      stackedComponents
          .addAll(buildRoundedRectangleEditingWidgets(currentShape));
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

  List<Widget> buildEditingShapeBasicPanelWidgets() {
    List<Widget> stackedComponents = [];

    stackedComponents.insert(
        0,
        buildRowWithHeaderText(
            headerText: "Shape Size",
            actionWidget: OffsetPicker(
                position: Offset(shapeSize.width, shapeSize.height),
                onPositionChanged: (Offset newPos) {
                  setState(() {
                    shapeSize = Size(
                        newPos.dx.clamp(shapeMinimumSize, double.infinity),
                        newPos.dy.clamp(shapeMinimumSize, double.infinity));
                  });
                },
                constraintSize: MediaQuery.of(context).size)));

    if (!(currentShape is PathShape)) {
      stackedComponents.add(buildRowWithHeaderText(
          headerText: "To Bezier",
          actionWidget: Container(
            padding: EdgeInsets.only(right: 5),
            child: ElevatedButton(
                child: Text('CONVERT'),
                onPressed: () {
                  setState(() {
                    updateCurrentShape(PathShape(
                        path: currentShape.generateOuterDynamicPath(
                            Rect.fromLTRB(
                                0, 0, shapeSize.width, shapeSize.height))
                          ..removeOverlappingNodes()));
                  });
                }),
          )));
    }

    stackedComponents.add(buildRowWithHeaderText(
        headerText: "Change Shape",
        actionWidget: Container(
          padding: EdgeInsets.only(right: 5),
          child: BottomSheetShapePicker(
            currentShape: currentShape,
            valueChanged: (value) {
              setState(() {
                updateCurrentShape(value);
              });
            },
          ),
        )));

    stackedComponents.add(buildRowWithHeaderText(
        headerText: "To Json",
        actionWidget: Container(
            padding: EdgeInsets.only(right: 5),
            child: IconButton(
                icon: Icon(Icons.code),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: SingleChildScrollView(
                          child: Container(
                              width: min(
                                  MediaQuery.of(context).size.width * 0.8, 400),
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
                }))));

    List<Widget> withDividerWidgets = [];
    stackedComponents.forEach((element) {
      withDividerWidgets.add(element);
      withDividerWidgets.add(Divider(
        thickness: 2,
      ));
    });

    return withDividerWidgets;
  }

  List<Widget> buildEditingShapePanelWidgets() {
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

    if (currentShape is RoundedRectangleShape) {
      stackedComponents
          .addAll(buildRoundedRectangleEditingPanelWidget(currentShape));
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

    List<Widget> withDividerWidgets = [];
    stackedComponents.forEach((element) {
      withDividerWidgets.add(element);
      withDividerWidgets.add(Divider(
        thickness: 2,
      ));
    });

    return withDividerWidgets;
  }

  List<Widget> buildEditingShapeBorderPanelWidgets() {
    List<Widget> stackedComponents = [];

    if (currentShape is OutlinedShape) {
      stackedComponents
          .addAll(buildOutlinedBorderEditingPanelWidget(currentShape));
    }

    if (currentShape is RoundedRectangleShape) {
      stackedComponents
          .addAll(buildRoundedRectangleBorderEditingPanelWidget(currentShape));
    }

    List<Widget> withDividerWidgets = [];
    stackedComponents.forEach((element) {
      withDividerWidgets.add(element);
      withDividerWidgets.add(Divider(
        thickness: 2,
      ));
    });

    return withDividerWidgets;
  }

  Widget buildAddControlPointButton(PathShape shape, int index) {
    DynamicPath path = shape.path;
    int nextIndex = (index + 1) % path.nodes.length;
    List<Offset> controlPoints = path.getNextPathControlPointsAt(index);
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
            updateCurrentShape(shape.copyWith(path: path));
            selectedNodeIndex = null;
          });
        },
        child: Container(
          width: 2 * nodeSize,
          height: 2 * nodeSize,
          decoration: ShapeDecoration(
              gradient: RadialGradient(
                  colors: [Colors.amber, Colors.amberAccent], stops: [0, 0.3]),
              shape: CircleBorder(side: BorderSide(width: 0))),
          alignment: Alignment.center,
          child: Icon(
            Icons.add,
            size: 2 * nodeSize * 0.8,
          ),
        ),
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
                      Offset destination = path
                              .getNodeWithControlPoints(selectedNodeIndex)
                              .position +
                          Offset(details.delta.dx, details.delta.dy)
                              .roundWithPrecision(2);
                      path.moveNodeTo(index, destination);
                      updateCurrentShape(shape.copyWith(path: path));
                    }
                  });
                },
                onPanEnd: (DragEndDetails details) {
                  setState(() {
                    if (selectedNodeIndex == index) {
                      if (snapToGrid) {
                        Offset destination = path
                            .getNodeWithControlPoints(selectedNodeIndex)
                            .position;
                        destination = Offset(
                          destination.dx
                              .roundWithNumber(2 * gridCount / shapeSize.width),
                          destination.dy.roundWithNumber(
                              2 * gridCount / shapeSize.height),
                        );
                        path.moveNodeTo(index, destination);
                        if (path.nodes[selectedNodeIndex].prev != null) {
                          path.moveNodeControlTo(
                              selectedNodeIndex,
                              true,
                              Offset(
                                path.nodes[selectedNodeIndex].prev.dx
                                    .roundWithNumber(
                                        2 * gridCount / shapeSize.width),
                                path.nodes[selectedNodeIndex].prev.dy
                                    .roundWithNumber(
                                        2 * gridCount / shapeSize.height),
                              ));
                        }
                        if (path.nodes[selectedNodeIndex].next != null) {
                          path.moveNodeControlTo(
                              selectedNodeIndex,
                              false,
                              Offset(
                                path.nodes[selectedNodeIndex].next.dx
                                    .roundWithNumber(
                                        2 * gridCount / shapeSize.width),
                                path.nodes[selectedNodeIndex].next.dy
                                    .roundWithNumber(
                                        2 * gridCount / shapeSize.height),
                              ));
                        }
                        updateCurrentShape(shape.copyWith(path: path));
                      }
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

      nodeControls.add(buildAddControlPointButton(shape, prevIndex));
      nodeControls.add(buildAddControlPointButton(shape, selectedNodeIndex));

      nodeControls.add(Positioned(
        left: tempSelectedNode.prev.dx,
        top: tempSelectedNode.prev.dy,
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              path.moveNodeControlTo(
                  selectedNodeIndex,
                  true,
                  path.getNodeWithControlPoints(selectedNodeIndex).prev +
                      Offset(details.delta.dx, details.delta.dy)
                          .roundWithPrecision(2));
              updateCurrentShape(shape.copyWith(path: path));
            });
          },
          onPanEnd: (DragEndDetails details) {
            setState(() {
              if (snapToGrid) {
                path.moveNodeControlTo(
                    selectedNodeIndex,
                    true,
                    Offset(
                      path.nodes[selectedNodeIndex].prev.dx
                          .roundWithNumber(2 * gridCount / shapeSize.width),
                      path.nodes[selectedNodeIndex].prev.dy
                          .roundWithNumber(2 * gridCount / shapeSize.height),
                    ));
                updateCurrentShape(shape.copyWith(path: path));
              }
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
                  path.getNodeWithControlPoints(selectedNodeIndex).next +
                      Offset(details.delta.dx, details.delta.dy)
                          .roundWithPrecision(2));
              updateCurrentShape(shape.copyWith(path: path));
            });
          },
          onPanEnd: (DragEndDetails details) {
            setState(() {
              if (snapToGrid) {
                path.moveNodeControlTo(
                    selectedNodeIndex,
                    false,
                    Offset(
                      path.nodes[selectedNodeIndex].next.dx
                          .roundWithNumber(2 * gridCount / shapeSize.width),
                      path.nodes[selectedNodeIndex].next.dy
                          .roundWithNumber(2 * gridCount / shapeSize.height),
                    ));
                updateCurrentShape(shape.copyWith(path: path));
              }
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

  Widget buildShapeEditingDragHandle(
      {Offset position, Function onDragUpdate, Color color = Colors.amber}) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
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

  Length updateLength(Length length,
      {double constraint,
      double minimumSize = 0.00,
      double maximumSize = double.infinity,
      Offset offset,
      double Function(Offset) offsetToDelta}) {
    double newValue = length.toPX(constraint: constraint) +
        1.0 * offsetToDelta(offset);
    return length.copyWith(
        value: Length.fromPX(
            newValue.clamp(minimumSize, maximumSize), length.unit,
            constraint: constraint));
  }

  List<Widget> buildArcEditingWidgets(ArcShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    double maximumSize = min(size.height, size.height) / 2;

    double arcHeight;
    if (shape.side.isHorizontal) {
      arcHeight = shape.arcHeight
          .toPX(constraint: size.height)
          .clamp(0, maximumSize);
    } else {
      arcHeight = shape.arcHeight
          .toPX(constraint: size.width)
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

    nodeControls.add(buildShapeEditingDragHandle(
        position: position,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            updateCurrentShape(shape.copyWith(
                arcHeight: updateLength((currentShape as ArcShape).arcHeight,
                    constraint:
                        shape.side.isHorizontal ? size.height : size.width,
                    maximumSize: maximumSize,
                    offset: details.delta,
                    offsetToDelta: dragOffsetToDelta)));
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
          .toPX(constraint: size.height)
          .clamp(0, size.height);
      tailWidth =
          shape.tailWidth.toPX(constraint: size.width).clamp(0, size.width);
    } else {
      arrowHeight = shape.arrowHeight
          .toPX(constraint: size.width)
          .clamp(0, size.width);
      tailWidth = shape.tailWidth
          .toPX(constraint: size.height)
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

    nodeControls.add(buildShapeEditingDragHandle(
        position: headPosition,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            updateCurrentShape(shape.copyWith(
                arrowHeight: updateLength(
                    (currentShape as ArrowShape).arrowHeight,
                    constraint:
                        shape.side.isHorizontal ? size.width : size.height,
                    maximumSize:
                        shape.side.isHorizontal ? size.width : size.height,
                    offset: details.delta,
                    offsetToDelta: headOffsetToDelta)));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        position: tailPosition,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            updateCurrentShape(shape.copyWith(
                tailWidth: updateLength((currentShape as ArrowShape).tailWidth,
                    constraint:
                        shape.side.isHorizontal ? size.height : size.width,
                    maximumSize:
                        shape.side.isHorizontal ? size.height : size.width,
                    offset: details.delta,
                    offsetToDelta: tailOffsetToDelta)));
          });
        }));

    return nodeControls;
  }

  List<Widget> buildCircleEditingWidgets(CircleShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    double startAngle = shape.startAngle.clamp(0.0, 2 * pi);
    double sweepAngle = shape.sweepAngle.clamp(0.0, 2 * pi);

    nodeControls.add(buildShapeEditingDragHandle(
        position: Offset(size.width / 2 * (1 + cos(startAngle)),
            size.height / 2 * (1 + sin(startAngle))),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            double startAngle = (currentShape as CircleShape).startAngle;
            Offset delta = details.delta;
            updateCurrentShape(shape.copyWith(
                startAngle: (startAngle +
                        (delta.dy * cos(startAngle) -
                                delta.dx * sin(startAngle)) /
                            (Offset(size.width / 2 * cos(startAngle),
                                    size.height / 2 * sin(startAngle))
                                .distance))
                    .clamp(0.0, 2 * pi)));
          });
        }));

    double endAngle = startAngle + sweepAngle;
    nodeControls.add(buildShapeEditingDragHandle(
        position: Offset(size.width / 2 * (1 + 1 / 2 * cos(endAngle)),
            size.height / 2 * (1 + 1 / 2 * sin(endAngle))),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            double sweepAngle = (currentShape as CircleShape).sweepAngle;
            double endAngle =
                (currentShape as CircleShape).startAngle + sweepAngle;
            Offset delta = details.delta;
            updateCurrentShape(shape.copyWith(
                sweepAngle: (sweepAngle +
                        (delta.dy * cos(endAngle) - delta.dx * sin(endAngle)) /
                            (Offset(size.width / 4 * cos(endAngle),
                                    size.height / 4 * sin(endAngle))
                                .distance))
                    .clamp(0.0, 2 * pi)));
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
        shape.borderRadius.toPX(constraint: min(size.height, size.width));
    if (corner.isHorizontal) {
      arrowHeight = shape.arrowHeight.toPX(constraint: size.height);
      arrowWidth = shape.arrowWidth.toPX(constraint: size.width);
      arrowCenterPosition =
          shape.arrowCenterPosition.toPX(constraint: size.width);
      arrowHeadPosition =
          shape.arrowHeadPosition.toPX(constraint: size.width);
    } else {
      arrowHeight = shape.arrowHeight.toPX(constraint: size.width);
      arrowWidth = shape.arrowWidth.toPX(constraint: size.height);
      arrowCenterPosition =
          shape.arrowCenterPosition.toPX(constraint: size.height);
      arrowHeadPosition =
          shape.arrowHeadPosition.toPX(constraint: size.height);
    }

    final double spacingLeft = shape.corner.isLeft ? arrowHeight : 0;
    final double spacingTop = shape.corner.isTop ? arrowHeight : 0;
    final double spacingRight = shape.corner.isRight ? arrowHeight : 0;
    final double spacingBottom = shape.corner.isBottom ? arrowHeight : 0;

    final double left = spacingLeft;
    final double top = spacingTop;
    final double right = size.width - spacingRight;
    final double bottom = size.height - spacingBottom;

    double arrowCenterPositionBound = 0,
        arrowHeadPositionBound = 0,
        arrowWidthBound = 0,
        arrowHeightBound = 0,
        radiusBound = 0;

    if (shape.corner.isHorizontal) {
      arrowCenterPositionBound = size.width;
      arrowHeadPositionBound = size.width;
      arrowCenterPosition =
          arrowCenterPosition.clamp(0.0, arrowCenterPositionBound);
      arrowHeadPosition = arrowHeadPosition.clamp(0.0, arrowHeadPositionBound);
      arrowHeightBound = size.height;
      arrowWidthBound =
          2 * min(arrowCenterPosition, size.width - arrowCenterPosition);
      arrowHeight = arrowHeight.clamp(0, arrowHeightBound);
      arrowWidth = arrowWidth.clamp(0.0, arrowWidthBound);
      radiusBound = min(
          min(right - arrowCenterPosition - arrowWidth / 2,
              arrowCenterPosition - arrowWidth / 2 - left),
          (bottom - top) / 2);
      borderRadius =
          borderRadius.clamp(0.0, radiusBound >= 0.0 ? radiusBound : 0.0);
    } else {
      arrowCenterPositionBound = size.height;
      arrowHeadPositionBound = size.height;
      arrowCenterPosition =
          arrowCenterPosition.clamp(0.0, arrowCenterPositionBound);
      arrowHeadPosition = arrowHeadPosition.clamp(0.0, arrowHeadPositionBound);
      arrowHeightBound = size.height;
      arrowWidthBound =
          2 * min(arrowCenterPosition, size.height - arrowCenterPosition);
      arrowHeight = arrowHeight.clamp(0, arrowHeightBound);
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

    nodeControls.add(buildShapeEditingDragHandle(
        position: arrowCenterOffset,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            updateCurrentShape(shape.copyWith(
                arrowHeight: updateLength(
                    (currentShape as BubbleShape).arrowHeight,
                    constraint:
                        shape.corner.isHorizontal ? size.height : size.width,
                    maximumSize: arrowHeightBound,
                    offset: details.delta,
                    offsetToDelta: arrowCenterDragUpdateVertical),
                arrowCenterPosition: updateLength(
                    (currentShape as BubbleShape).arrowCenterPosition,
                    constraint:
                        shape.corner.isHorizontal ? size.width : size.height,
                    maximumSize: arrowCenterPositionBound,
                    offset: details.delta,
                    offsetToDelta: arrowCenterDragUpdateHorizontal)));
          });
        }));
    nodeControls.add(buildShapeEditingDragHandle(
        position: arrowWidthOffset,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            updateCurrentShape(shape.copyWith(
                arrowWidth: updateLength(
                    (currentShape as BubbleShape).arrowWidth,
                    constraint:
                        shape.corner.isHorizontal ? size.width : size.height,
                    maximumSize: arrowWidthBound,
                    offset: details.delta,
                    offsetToDelta: arrowWidthDragUpdate)));
          });
        }));
    nodeControls.add(buildShapeEditingDragHandle(
        position: arrowHeadOffset,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            updateCurrentShape(shape.copyWith(
                arrowHeadPosition: updateLength(
                    (currentShape as BubbleShape).arrowHeadPosition,
                    constraint:
                        shape.corner.isHorizontal ? size.width : size.height,
                    maximumSize: arrowHeadPositionBound,
                    offset: details.delta,
                    offsetToDelta: arrowHeadDragUpdate)));
          });
        }));
    nodeControls.add(buildShapeEditingDragHandle(
        position: radiusOffset,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            updateCurrentShape(shape.copyWith(
                borderRadius: updateLength(
                    (currentShape as BubbleShape).borderRadius,
                    constraint: min(size.width, size.height),
                    maximumSize: radiusBound,
                    offset: details.delta,
                    offsetToDelta: radiusDragUpdate)));
          });
        }));

    return nodeControls;
  }

  List<Widget> buildRectangleEditingWidgets(RectangleShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    BorderRadius borderRadius = shape.borderRadius.toBorderRadius(size: size);

    double topLeftRadius = borderRadius.topLeft.x.clamp(0, size.width);
    double topRightRadius = borderRadius.topRight.x.clamp(0, size.width);

    double bottomLeftRadius = borderRadius.bottomLeft.x.clamp(0, size.width);
    double bottomRightRadius = borderRadius.bottomRight.x.clamp(0, size.width);

    double leftTopRadius = borderRadius.topLeft.y.clamp(0, size.height);
    double leftBottomRadius = borderRadius.bottomLeft.y.clamp(0, size.height);

    double rightTopRadius = borderRadius.topRight.y.clamp(0, size.height);
    double rightBottomRadius = borderRadius.bottomRight.y.clamp(0, size.height);

    nodeControls.add(buildShapeEditingDragHandle(
        position: Offset(topLeftRadius, 0),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topLeft.copyWith(
                x: updateLength(
                    (currentShape as RectangleShape).borderRadius.topLeft.x,
                    constraint: size.width,
                    maximumSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dx));

            updateCurrentShape(shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topLeft: newRadius)));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        color: Colors.green,
        position: Offset(size.width - topRightRadius, 0),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topRight.copyWith(
                x: updateLength(
                    (currentShape as RectangleShape).borderRadius.topRight.x,
                    constraint: size.width,
                    maximumSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dx));

            updateCurrentShape(shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(topRight: newRadius)));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        color: Colors.blue,
        position: Offset(bottomLeftRadius, size.height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomLeft.copyWith(
                x: updateLength(
                    (currentShape as RectangleShape).borderRadius.bottomLeft.x,
                    constraint: size.width,
                    maximumSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dx));

            updateCurrentShape(shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomLeft: newRadius)));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        color: Colors.red,
        position: Offset(size.width - bottomRightRadius, size.height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomRight.copyWith(
                x: updateLength(
                    (currentShape as RectangleShape).borderRadius.bottomRight.x,
                    constraint: size.width,
                    maximumSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dx));

            updateCurrentShape(shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomRight: newRadius)));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        position: Offset(0, leftTopRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topLeft.copyWith(
                y: updateLength(
                    (currentShape as RectangleShape).borderRadius.topLeft.y,
                    constraint: size.height,
                    maximumSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dy));

            updateCurrentShape(shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topLeft: newRadius)));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        color: Colors.green,
        position: Offset(size.width, rightTopRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topRight.copyWith(
                y: updateLength(
                    (currentShape as RectangleShape).borderRadius.topRight.y,
                    constraint: size.height,
                    maximumSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dy));

            updateCurrentShape(shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(topRight: newRadius)));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        color: Colors.blue,
        position: Offset(0, size.height - leftBottomRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomLeft.copyWith(
                y: updateLength(
                    (currentShape as RectangleShape).borderRadius.bottomLeft.y,
                    constraint: size.height,
                    maximumSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dy));

            updateCurrentShape(shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomLeft: newRadius)));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        color: Colors.red,
        position: Offset(size.width, size.height - rightBottomRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomRight.copyWith(
                y: updateLength(
                    (currentShape as RectangleShape).borderRadius.bottomRight.y,
                    constraint: size.height,
                    maximumSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dy));

            updateCurrentShape(shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomRight: newRadius)));
          });
        }));

    return nodeControls;
  }

  List<Widget> buildRoundedRectangleEditingWidgets(
      RoundedRectangleShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    BorderRadius borderRadius = shape.borderRadius.toBorderRadius(size: size);

    double topLeftRadius = borderRadius.topLeft.x.clamp(0, size.width);
    double topRightRadius = borderRadius.topRight.x.clamp(0, size.width);

    double bottomLeftRadius = borderRadius.bottomLeft.x.clamp(0, size.width);
    double bottomRightRadius = borderRadius.bottomRight.x.clamp(0, size.width);

    double leftTopRadius = borderRadius.topLeft.y.clamp(0, size.height);
    double leftBottomRadius = borderRadius.bottomLeft.y.clamp(0, size.height);

    double rightTopRadius = borderRadius.topRight.y.clamp(0, size.height);
    double rightBottomRadius = borderRadius.bottomRight.y.clamp(0, size.height);

    nodeControls.add(buildShapeEditingDragHandle(
        position: Offset(topLeftRadius, 0),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topLeft.copyWith(
                x: updateLength(
                    (currentShape as RoundedRectangleShape)
                        .borderRadius
                        .topLeft
                        .x,
                    constraint: size.width,
                    maximumSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dx));

            updateCurrentShape(shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topLeft: newRadius)));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        color: Colors.green,
        position: Offset(size.width - topRightRadius, 0),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topRight.copyWith(
                x: updateLength(
                    (currentShape as RoundedRectangleShape)
                        .borderRadius
                        .topRight
                        .x,
                    constraint: size.width,
                    maximumSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dx));

            updateCurrentShape(shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(topRight: newRadius)));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        color: Colors.blue,
        position: Offset(bottomLeftRadius, size.height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomLeft.copyWith(
                x: updateLength(
                    (currentShape as RoundedRectangleShape)
                        .borderRadius
                        .bottomLeft
                        .x,
                    constraint: size.width,
                    maximumSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dx));

            updateCurrentShape(shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomLeft: newRadius)));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        color: Colors.red,
        position: Offset(size.width - bottomRightRadius, size.height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomRight.copyWith(
                x: updateLength(
                    (currentShape as RoundedRectangleShape)
                        .borderRadius
                        .bottomRight
                        .x,
                    constraint: size.width,
                    maximumSize: size.width,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dx));

            updateCurrentShape(shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomRight: newRadius)));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        position: Offset(0, leftTopRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topLeft.copyWith(
                y: updateLength(
                    (currentShape as RoundedRectangleShape)
                        .borderRadius
                        .topLeft
                        .y,
                    constraint: size.height,
                    maximumSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dy));

            updateCurrentShape(shape.copyWith(
                borderRadius: shape.borderRadius.copyWith(topLeft: newRadius)));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        color: Colors.green,
        position: Offset(size.width, rightTopRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.topRight.copyWith(
                y: updateLength(
                    (currentShape as RoundedRectangleShape)
                        .borderRadius
                        .topRight
                        .y,
                    constraint: size.height,
                    maximumSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => o.dy));

            updateCurrentShape(shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(topRight: newRadius)));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        color: Colors.blue,
        position: Offset(0, size.height - leftBottomRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomLeft.copyWith(
                y: updateLength(
                    (currentShape as RoundedRectangleShape)
                        .borderRadius
                        .bottomLeft
                        .y,
                    constraint: size.height,
                    maximumSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dy));

            updateCurrentShape(shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomLeft: newRadius)));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        color: Colors.red,
        position: Offset(size.width, size.height - rightBottomRadius),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicRadius newRadius = shape.borderRadius.bottomRight.copyWith(
                y: updateLength(
                    (currentShape as RoundedRectangleShape)
                        .borderRadius
                        .bottomRight
                        .y,
                    constraint: size.height,
                    maximumSize: size.height,
                    offset: details.delta,
                    offsetToDelta: (o) => -o.dy));

            updateCurrentShape(shape.copyWith(
                borderRadius:
                    shape.borderRadius.copyWith(bottomRight: newRadius)));
          });
        }));

    return nodeControls;
  }

  List<Widget> buildPolygonEditingWidgets(PolygonShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    double scale = min(size.width, size.height) / 2;
    double cornerRadius = shape.cornerRadius.toPX(constraint: scale);
    int sides = shape.sides;

    final height = 2 * scale;
    final width = 2 * scale;

    double startAngle = -pi / 2;

    final double alpha = (2.0 * pi / sides) / 2;
    final double centerX = width / 2;
    final double centerY = height / 2;

    cornerRadius = cornerRadius.clamp(0, scale * cos(alpha));

    double arcCenterRadius = scale - cornerRadius / sin(pi / 2 - alpha);

    double arcCenterX = (centerX + arcCenterRadius * cos(startAngle));
    double arcCenterY = (centerY + arcCenterRadius * sin(startAngle));

    Offset start = arcToCubicBezier(
            Rect.fromCircle(
                center: Offset(arcCenterX, arcCenterY), radius: cornerRadius),
            startAngle - alpha,
            2 * alpha,
            splitTimes: 1)
        .first;

    nodeControls.add(buildShapeEditingDragHandle(
        position: start.scale(size.width / width, size.height / height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            updateCurrentShape(shape.copyWith(
                cornerRadius: updateLength(
                    (currentShape as PolygonShape).cornerRadius,
                    constraint: scale,
                    maximumSize: scale * cos(alpha / 2),
                    offset: details.delta,
                    offsetToDelta: (o) => o.dy / sin(alpha))));
          });
        }));

    return nodeControls;
  }

  List<Widget> buildStarEditingWidgets(StarShape shape) {
    List<Widget> nodeControls = [];

    Size size = shapeSize;

    double scale = min(size.width, size.height) / 2;
    double cornerRadius = shape.cornerRadius.toPX(constraint: scale);
    double insetRadius = shape.insetRadius.toPX(constraint: scale);

    final height = 2 * scale;
    final width = 2 * scale;

    final int vertices = shape.corners * 2;
    final double alpha = (2 * pi) / vertices;
    final double radius = scale;
    final double centerX = width / 2;
    final double centerY = height / 2;

    double inset = shape.inset.toPX(constraint: radius);
    inset = inset.clamp(0.0, radius * 0.9999);
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

    double omega = -pi / 2;
    double r = radius - cornerRadius / sin(beta);
    Offset center =
        Offset((r * cos(omega)) + centerX, (r * sin(omega)) + centerY);
    double sweepAngle = 2 * (pi / 2 - beta);
    Offset start = arcToCubicBezier(
            Rect.fromCircle(center: center, radius: cornerRadius),
            omega - sweepAngle / 2,
            sweepAngle)
        .first;

    nodeControls.add(buildShapeEditingDragHandle(
        position: start.scale(size.width / width, size.height / height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            updateCurrentShape(shape.copyWith(
                cornerRadius: updateLength(
                    (currentShape as StarShape).cornerRadius,
                    constraint: scale,
                    maximumSize: sideLength * tan(beta),
                    offset: details.delta,
                    offsetToDelta: (o) => o.dy / cos(beta) * tan(beta))));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        position: Offset(centerX + (radius - inset) * cos(-pi / 2 + alpha),
                centerY + (radius - inset) * sin(-pi / 2 + (alpha)))
            .scale(size.width / width, size.height / height),
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            updateCurrentShape(shape.copyWith(
                inset: updateLength((currentShape as StarShape).inset,
                    constraint: radius,
                    maximumSize: radius * 0.99,
                    offset: details.delta,
                    offsetToDelta: (o) => (-o.dx / cos(-pi / 2 + alpha)))));
          });
        }));

    omega = -pi / 2 - alpha;
    sweepAngle = pi - 2 * gamma;

    if (gamma <= pi / 2) {
      r = radius - inset + insetRadius / sin(gamma);
      Offset center =
          Offset((r * cos(omega)) + centerX, (r * sin(omega)) + centerY);
      Offset start = arcToCubicBezier(
              Rect.fromCircle(center: center, radius: insetRadius),
              omega + sweepAngle / 2 + pi,
              -sweepAngle)
          .first;
      nodeControls.add(buildShapeEditingDragHandle(
          position: start.scale(size.width / width, size.height / height),
          onDragUpdate: (DragUpdateDetails details) {
            setState(() {
              updateCurrentShape(shape.copyWith(
                  insetRadius: updateLength(
                      (currentShape as StarShape).insetRadius,
                      constraint: scale,
                      maximumSize: avalSideLength * tan(gamma),
                      offset: details.delta,
                      offsetToDelta: (o) =>
                          (o.dx * cos(omega - gamma) +
                              o.dy * sin(omega - gamma)) *
                          tan(gamma))));
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
              sweepAngle)
          .first;
      nodeControls.add(buildShapeEditingDragHandle(
          position: start.scale(size.width / width, size.height / height),
          onDragUpdate: (DragUpdateDetails details) {
            setState(() {
              updateCurrentShape(shape.copyWith(
                  insetRadius: updateLength(
                      (currentShape as StarShape).insetRadius,
                      constraint: scale,
                      maximumSize: avalSideLength * tan(pi - gamma),
                      offset: details.delta,
                      offsetToDelta: (o) =>
                          -(o.dx * cos(omega - gamma) +
                              o.dy * sin(omega - gamma)) *
                          tan(gamma))));
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
          shape.inset.toPX(constraint: size.width).clamp(0, size.width / 2);
    } else {
      inset = shape.inset
          .toPX(constraint: size.height)
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

    nodeControls.add(buildShapeEditingDragHandle(
      position: position,
      onDragUpdate: (DragUpdateDetails details) {
        setState(() {
          updateCurrentShape(shape.copyWith(
              inset: updateLength((currentShape as TrapezoidShape).inset,
                  constraint:
                      shape.side.isHorizontal ? size.width : size.height,
                  maximumSize: shape.side.isHorizontal
                      ? size.width / 2
                      : size.height / 2,
                  offset: details.delta,
                  offsetToDelta: onDragUpdate)));
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

    Offset point3 = shape.point3
        .toOffset(size: size)
        .clamp(Offset.zero, Offset(width, height));
    Offset point2 = shape.point2
        .toOffset(size: size)
        .clamp(Offset.zero, Offset(width, height));
    Offset point1 = shape.point1
        .toOffset(size: size)
        .clamp(Offset.zero, Offset(width, height));

    nodeControls.add(buildShapeEditingDragHandle(
        position: point3,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicOffset newOffset = shape.point3.copyWith(
                dx: updateLength((currentShape as TriangleShape).point3.dx,
                    constraint: width,
                    maximumSize: width,
                    offset: details.delta,
                    offsetToDelta: (o) => (o.dx)),
                dy: updateLength((currentShape as TriangleShape).point3.dy,
                    constraint: height,
                    maximumSize: height,
                    offset: details.delta,
                    offsetToDelta: (o) => (o.dy)));
            updateCurrentShape(shape.copyWith(point3: newOffset));
          });
        }));
    nodeControls.add(buildShapeEditingDragHandle(
        position: point2,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicOffset newOffset = shape.point2.copyWith(
                dx: updateLength((currentShape as TriangleShape).point2.dx,
                    constraint: width,
                    maximumSize: width,
                    offset: details.delta,
                    offsetToDelta: (o) => (o.dx)),
                dy: updateLength((currentShape as TriangleShape).point2.dy,
                    constraint: height,
                    maximumSize: height,
                    offset: details.delta,
                    offsetToDelta: (o) => (o.dy)));
            updateCurrentShape(shape.copyWith(point2: newOffset));
          });
        }));

    nodeControls.add(buildShapeEditingDragHandle(
        position: point1,
        onDragUpdate: (DragUpdateDetails details) {
          setState(() {
            DynamicOffset newOffset = shape.point1.copyWith(
                dx: updateLength((currentShape as TriangleShape).point1.dx,
                    constraint: width,
                    maximumSize: width,
                    offset: details.delta,
                    offsetToDelta: (o) => (o.dx)),
                dy: updateLength((currentShape as TriangleShape).point1.dy,
                    constraint: height,
                    maximumSize: height,
                    offset: details.delta,
                    offsetToDelta: (o) => (o.dy)));
            updateCurrentShape(shape.copyWith(point1: newOffset));
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
                  fontWeight: FontWeight.w500, letterSpacing: 1, fontSize: 16),
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
                //print("new pos: " + newPos.toString());
                path.moveNodeTo(selectedNodeIndex, newPos);
                updateCurrentShape(shape.copyWith(path: path));
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
                      updateCurrentShape(shape.copyWith(path: path));
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
                      updateCurrentShape(shape.copyWith(path: path));
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
                    updateCurrentShape(shape.copyWith(path: path));
                    selectedNodeIndex = null;
                  });
                }),
          )));
    }

    rst.add(buildRowWithHeaderText(
        headerText: "Show Grid",
        actionWidget: Container(
          padding: EdgeInsets.only(right: 5),
          child: Switch(
            value: showGrid,
            onChanged: (value) {
              setState(() {
                showGrid = value;
                if (!showGrid) {
                  snapToGrid = false;
                }
              });
            },
          ),
        )));

    if (showGrid) {
      rst.add(buildRowWithHeaderText(
          headerText: "Snap to Grid",
          actionWidget: Container(
            padding: EdgeInsets.only(right: 5),
            child: Switch(
              value: snapToGrid,
              onChanged: (value) {
                setState(() {
                  snapToGrid = value;
                });
              },
            ),
          )));
      rst.add(buildRowWithHeaderText(
          headerText: "Grid Count",
          actionWidget: Container(
            padding: EdgeInsets.only(right: 5),
            child: Slider(
              label: gridCount.toString(),
              value: gridCount.toDouble(),
              min: 2,
              max: 60,
              divisions: 58,
              onChanged: (value) {
                setState(() {
                  gridCount = value.round();
                });
              },
            ),
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
                updateCurrentShape(shape.copyWith(side: newSide));
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
                updateCurrentShape(shape.copyWith(isOutward: value));
              });
            })));

    rst.add(buildRowWithHeaderText(
      headerText: "Arc Height",
      actionWidget: Expanded(
        child: LengthSlider(
          sliderValue: shape.arcHeight,
          valueChanged: (value) {
            setState(() {
              updateCurrentShape(shape.copyWith(arcHeight: value));
            });
          },
          constraint: shape.side.isHorizontal ? size.height : size.width,
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
                updateCurrentShape(shape.copyWith(side: newSide));
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
              updateCurrentShape(shape.copyWith(arrowHeight: value));
            });
          },
          constraint: shape.side.isHorizontal ? size.height : size.width,
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
              updateCurrentShape(shape.copyWith(tailWidth: value));
            });
          },
          constraint: shape.side.isHorizontal ? size.width : size.height,
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
                updateCurrentShape(shape.copyWith(corner: value));
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
                updateCurrentShape(shape.copyWith(arrowCenterPosition: value));
              });
            },
            constraint:
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
              updateCurrentShape(shape.copyWith(arrowHeadPosition: value));
            });
          },
          constraint: shape.corner.isHorizontal ? size.width : size.height,
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
                updateCurrentShape(shape.copyWith(arrowHeight: value));
              });
            },
            constraint:
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
              updateCurrentShape(shape.copyWith(arrowWidth: value));
            });
          },
          constraint: shape.corner.isHorizontal ? size.width : size.height,
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
              updateCurrentShape(shape.copyWith(borderRadius: value));
            });
          },
          constraint: min(size.width, size.height),
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
              updateCurrentShape(shape.copyWith(startAngle: value / 180 * pi));
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
              updateCurrentShape(shape.copyWith(sweepAngle: value / 180 * pi));
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
                updateCurrentShape(shape.copyWith(sides: newSide));
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
                updateCurrentShape(shape.copyWith(cornerStyle: newSide));
              });
            },
            items: [
              CornerStyle.rounded,
              CornerStyle.straight,
              CornerStyle.cutout,
              CornerStyle.concave,
            ]
                .map((e) => DropdownMenuItem(value: e, child: Text(e.toJson())))
                .toList())));

    rst.add(buildRowWithHeaderText(
      headerText: "Corner Radius",
      actionWidget: Expanded(
        child: LengthSlider(
          sliderValue: shape.cornerRadius,
          valueChanged: (value) {
            setState(() {
              updateCurrentShape(shape.copyWith(cornerRadius: value));
            });
          },
          constraint: min(size.width, size.height),
          allowedUnits: ["px", "%"],
        ),
      ),
    ));

    return rst;
  }

  List<Widget> buildRectangleEditingPanelWidget(RectangleShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Top Left:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        buildRowWithHeaderText(
            headerText: "Style",
            actionWidget: DropdownButton<CornerStyle>(
                value: shape.cornerStyles.topLeft,
                onChanged: (CornerStyle newSide) {
                  setState(() {
                    updateCurrentShape(shape.copyWith(
                        cornerStyles:
                            shape.cornerStyles.copyWith(topLeft: newSide)));
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
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          topLeft:
                              shape.borderRadius.topLeft.copyWith(x: value))));
                });
              },
              constraint: size.width,
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
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          topLeft:
                              shape.borderRadius.topLeft.copyWith(y: value))));
                });
              },
              constraint: size.height,
              allowedUnits: ["px", "%"],
            ),
          ),
        )
      ],
    ));

    rst.add(Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Top Right:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        buildRowWithHeaderText(
            headerText: "Style",
            actionWidget: DropdownButton<CornerStyle>(
                value: shape.cornerStyles.topRight,
                onChanged: (CornerStyle newSide) {
                  setState(() {
                    updateCurrentShape(shape.copyWith(
                        cornerStyles:
                            shape.cornerStyles.copyWith(topRight: newSide)));
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
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          topRight:
                              shape.borderRadius.topRight.copyWith(x: value))));
                });
              },
              constraint: size.width,
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
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          topRight:
                              shape.borderRadius.topRight.copyWith(y: value))));
                });
              },
              constraint: size.height,
              allowedUnits: ["px", "%"],
            ),
          ),
        )
      ],
    ));

    rst.add(Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Bottom Left:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        buildRowWithHeaderText(
            headerText: "Style",
            actionWidget: DropdownButton<CornerStyle>(
                value: shape.cornerStyles.bottomLeft,
                onChanged: (CornerStyle newSide) {
                  setState(() {
                    updateCurrentShape(shape.copyWith(
                        cornerStyles:
                            shape.cornerStyles.copyWith(bottomLeft: newSide)));
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
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          bottomLeft: shape.borderRadius.bottomLeft
                              .copyWith(x: value))));
                });
              },
              constraint: size.width,
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
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          bottomLeft: shape.borderRadius.bottomLeft
                              .copyWith(y: value))));
                });
              },
              constraint: size.height,
              allowedUnits: ["px", "%"],
            ),
          ),
        )
      ],
    ));

    rst.add(Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Bottom Right:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        buildRowWithHeaderText(
            headerText: "Style",
            actionWidget: DropdownButton<CornerStyle>(
                value: shape.cornerStyles.bottomRight,
                onChanged: (CornerStyle newSide) {
                  setState(() {
                    updateCurrentShape(shape.copyWith(
                        cornerStyles:
                            shape.cornerStyles.copyWith(bottomRight: newSide)));
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
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          bottomRight: shape.borderRadius.bottomRight
                              .copyWith(x: value))));
                });
              },
              constraint: size.width,
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
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          bottomRight: shape.borderRadius.bottomRight
                              .copyWith(y: value))));
                });
              },
              constraint: size.height,
              allowedUnits: ["px", "%"],
            ),
          ),
        )
      ],
    ));

    return rst;
  }

  List<Widget> buildRoundedRectangleEditingPanelWidget(
      RoundedRectangleShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Top Left:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        buildRowWithHeaderText(
          headerText: "X",
          actionWidget: Expanded(
            child: LengthSlider(
              sliderValue: shape.borderRadius.topLeft.x,
              valueChanged: (value) {
                setState(() {
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          topLeft:
                              shape.borderRadius.topLeft.copyWith(x: value))));
                });
              },
              constraint: size.width,
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
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          topLeft:
                              shape.borderRadius.topLeft.copyWith(y: value))));
                });
              },
              constraint: size.height,
              allowedUnits: ["px", "%"],
            ),
          ),
        )
      ],
    ));

    rst.add(Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Top Right:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        buildRowWithHeaderText(
          headerText: "X",
          actionWidget: Expanded(
            child: LengthSlider(
              sliderColor: Colors.green,
              sliderValue: shape.borderRadius.topRight.x,
              valueChanged: (value) {
                setState(() {
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          topRight:
                              shape.borderRadius.topRight.copyWith(x: value))));
                });
              },
              constraint: size.width,
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
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          topRight:
                              shape.borderRadius.topRight.copyWith(y: value))));
                });
              },
              constraint: size.height,
              allowedUnits: ["px", "%"],
            ),
          ),
        )
      ],
    ));

    rst.add(Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Bottom Left:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        buildRowWithHeaderText(
          headerText: "X",
          actionWidget: Expanded(
            child: LengthSlider(
              sliderColor: Colors.blue,
              sliderValue: shape.borderRadius.bottomLeft.x,
              valueChanged: (value) {
                setState(() {
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          bottomLeft: shape.borderRadius.bottomLeft
                              .copyWith(x: value))));
                });
              },
              constraint: size.width,
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
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          bottomLeft: shape.borderRadius.bottomLeft
                              .copyWith(y: value))));
                });
              },
              constraint: size.height,
              allowedUnits: ["px", "%"],
            ),
          ),
        )
      ],
    ));

    rst.add(Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Bottom Right:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        buildRowWithHeaderText(
          headerText: "X",
          actionWidget: Expanded(
            child: LengthSlider(
              sliderColor: Colors.red,
              sliderValue: shape.borderRadius.bottomRight.x,
              valueChanged: (value) {
                setState(() {
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          bottomRight: shape.borderRadius.bottomRight
                              .copyWith(x: value))));
                });
              },
              constraint: size.width,
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
                  updateCurrentShape(shape.copyWith(
                      borderRadius: shape.borderRadius.copyWith(
                          bottomRight: shape.borderRadius.bottomRight
                              .copyWith(y: value))));
                });
              },
              constraint: size.height,
              allowedUnits: ["px", "%"],
            ),
          ),
        )
      ],
    ));

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
                updateCurrentShape(shape.copyWith(corners: newSide));
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
                updateCurrentShape(shape.copyWith(cornerStyle: newSide));
              });
            },
            items: CornerStyle.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.toJson())))
                .toList())));

    rst.add(buildRowWithHeaderText(
      headerText: "Corner Radius",
      actionWidget: Expanded(
        child: LengthSlider(
          sliderValue: shape.cornerRadius,
          valueChanged: (value) {
            setState(() {
              updateCurrentShape(shape.copyWith(cornerRadius: value));
            });
          },
          constraint: min(size.width, size.height),
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
              updateCurrentShape(shape.copyWith(inset: value));
            });
          },
          constraint: min(size.width, size.height),
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
                updateCurrentShape(shape.copyWith(insetStyle: newSide));
              });
            },
            items: CornerStyle.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.toJson())))
                .toList())));

    rst.add(buildRowWithHeaderText(
      headerText: "Inset Radius",
      actionWidget: Expanded(
        child: LengthSlider(
          sliderValue: shape.insetRadius,
          valueChanged: (value) {
            setState(() {
              updateCurrentShape(shape.copyWith(insetRadius: value));
            });
          },
          constraint: min(size.width, size.height),
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
                updateCurrentShape(shape.copyWith(side: newSide));
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
              updateCurrentShape(shape.copyWith(inset: value));
            });
          },
          constraint: shape.side.isHorizontal ? size.width : size.height,
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
              value: (shape.point1.dx as Length).value,
              onValueChanged: (double value) {
                updateCurrentShape(shape.copyWith(
                    point1: shape.point1.copyWith(dx: value.toPercentLength)));
              },
              unit: "%",
            ),
            Container(
              width: 10,
            ),
            Text("Y  "),
            FixedUnitValuePicker(
              value: (shape.point1.dy as Length).value,
              onValueChanged: (double value) {
                updateCurrentShape(shape.copyWith(
                    point1: shape.point1.copyWith(dy: value.toPercentLength)));
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
              value: (shape.point2.dx as Length).value,
              onValueChanged: (double value) {
                updateCurrentShape(shape.copyWith(
                    point2: shape.point1.copyWith(dx: value.toPercentLength)));
              },
              unit: "%",
            ),
            Container(
              width: 10,
            ),
            Text("Y  "),
            FixedUnitValuePicker(
              value: (shape.point2.dy as Length).value,
              onValueChanged: (double value) {
                updateCurrentShape(shape.copyWith(
                    point2: shape.point1.copyWith(dy: value.toPercentLength)));
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
              value: (shape.point3.dx as Length).value,
              onValueChanged: (double value) {
                updateCurrentShape(shape.copyWith(
                    point1: shape.point3.copyWith(dx: value.toPercentLength)));
              },
              unit: "%",
            ),
            Container(
              width: 10,
            ),
            Text("Y  "),
            FixedUnitValuePicker(
              value: (shape.point3.dy as Length).value,
              onValueChanged: (double value) {
                updateCurrentShape(shape.copyWith(
                    point1: shape.point3.copyWith(dy: value.toPercentLength)));
              },
              unit: "%",
            ),
          ],
        ),
      ),
    ));

    return rst;
  }

  List<Widget> buildOutlinedBorderEditingPanelWidget(OutlinedShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    DynamicBorderSide border = shape.border;

    rst.add(buildRowWithHeaderText(
        headerText: "Border Width",
        actionWidget: Expanded(
          child: Slider(
            value: border.width,
            onChanged: (value) {
              setState(() {
                updateCurrentShape(
                    shape.copyWith(border: border.copyWith(width: value)));
              });
            },
            min: 0,
            max: 20,
            divisions: 20,
          ),
        )));

    rst.add(buildRowWithHeaderText(
        headerText: "Border Color",
        actionWidget: BottomSheetColorPicker(
          currentColor: border.color,
          valueChanged: (value) {
            setState(() {
              DynamicBorderSide newBorder =
                  DynamicBorderSide(width: border.width, color: value);
              updateCurrentShape(shape.copyWith(border: newBorder));
            });
          },
        )));

    rst.add(buildRowWithHeaderText(
        headerText: "Border Gradient",
        actionWidget: BottomSheetGradientPicker(
          currentGradient: border.gradient,
          valueChanged: (value) {
            setState(() {
              DynamicBorderSide newBorder = DynamicBorderSide(
                width: border.width,
                color: border.color,
                gradient: value,
              );
              updateCurrentShape(shape.copyWith(border: newBorder));
            });
          },
        )));

    return rst;
  }

  List<Widget> buildRoundedRectangleBorderEditingPanelWidget(
      RoundedRectangleShape shape) {
    Size size = shapeSize;
    List<Widget> rst = [];

    rst.add(Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Top Border:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        buildRowWithHeaderText(
            headerText: "Width",
            actionWidget: Expanded(
              child: Slider(
                value: shape.borders.top.width,
                onChanged: (value) {
                  setState(() {
                    updateCurrentShape(shape.copyWith(
                        borders: shape.borders.copyWith(
                            top: shape.borders.top.copyWith(width: value))));
                  });
                },
                min: 0,
                max: 20,
                divisions: 20,
              ),
            )),
        buildRowWithHeaderText(
            headerText: "Color",
            actionWidget: BottomSheetColorPicker(
              currentColor: shape.borders.top.color,
              valueChanged: (value) {
                setState(() {
                  DynamicBorderSide newBorder = DynamicBorderSide(
                    width: shape.borders.top.width,
                    color: value,
                  );
                  updateCurrentShape(shape.copyWith(
                      borders: shape.borders.copyWith(top: newBorder)));
                });
              },
            )),
        buildRowWithHeaderText(
            headerText: "Gradient",
            actionWidget: BottomSheetGradientPicker(
              currentGradient: shape.borders.top.gradient,
              valueChanged: (value) {
                setState(() {
                  DynamicBorderSide newBorder = DynamicBorderSide(
                    width: shape.borders.top.width,
                    color: shape.borders.top.color,
                    gradient: value,
                  );
                  updateCurrentShape(shape.copyWith(
                      borders: shape.borders.copyWith(top: newBorder)));
                });
              },
            ))
      ],
    ));

    rst.add(Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Right Border:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        buildRowWithHeaderText(
            headerText: "Width",
            actionWidget: Expanded(
              child: Slider(
                value: shape.borders.right.width,
                onChanged: (value) {
                  setState(() {
                    updateCurrentShape(shape.copyWith(
                        borders: shape.borders.copyWith(
                            right: shape.borders.right.copyWith(width: value))));
                  });
                },
                min: 0,
                max: 20,
                divisions: 20,
              ),
            )),
        buildRowWithHeaderText(
            headerText: "Color",
            actionWidget: BottomSheetColorPicker(
              currentColor: shape.borders.right.color,
              valueChanged: (value) {
                setState(() {
                  DynamicBorderSide newBorder = DynamicBorderSide(
                    width: shape.borders.right.width,
                    color: value,
                  );
                  updateCurrentShape(shape.copyWith(
                      borders: shape.borders.copyWith(right: newBorder)));
                });
              },
            )),
        buildRowWithHeaderText(
            headerText: "Gradient",
            actionWidget: BottomSheetGradientPicker(
              currentGradient: shape.borders.right.gradient,
              valueChanged: (value) {
                setState(() {
                  DynamicBorderSide newBorder = DynamicBorderSide(
                    width: shape.borders.right.width,
                    color: shape.borders.right.color,
                    gradient: value,
                  );
                  updateCurrentShape(shape.copyWith(
                      borders: shape.borders.copyWith(right: newBorder)));
                });
              },
            ))
      ],
    ));

    rst.add(Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Bottom Border:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        buildRowWithHeaderText(
            headerText: "Width",
            actionWidget: Expanded(
              child: Slider(
                value: shape.borders.bottom.width,
                onChanged: (value) {
                  setState(() {
                    updateCurrentShape(shape.copyWith(
                        borders: shape.borders.copyWith(
                            bottom: shape.borders.bottom.copyWith(width: value))));
                  });
                },
                min: 0,
                max: 20,
                divisions: 20,
              ),
            )),
        buildRowWithHeaderText(
            headerText: "Color",
            actionWidget: BottomSheetColorPicker(
              currentColor: shape.borders.bottom.color,
              valueChanged: (value) {
                setState(() {
                  DynamicBorderSide newBorder = DynamicBorderSide(
                    width: shape.borders.bottom.width,
                    color: value,
                  );
                  updateCurrentShape(shape.copyWith(
                      borders: shape.borders.copyWith(bottom: newBorder)));
                });
              },
            )),
        buildRowWithHeaderText(
            headerText: "Gradient",
            actionWidget: BottomSheetGradientPicker(
              currentGradient: shape.borders.bottom.gradient,
              valueChanged: (value) {
                setState(() {
                  DynamicBorderSide newBorder = DynamicBorderSide(
                    width: shape.borders.bottom.width,
                    color: shape.borders.bottom.color,
                    gradient: value,
                  );
                  updateCurrentShape(shape.copyWith(
                      borders: shape.borders.copyWith(bottom: newBorder)));
                });
              },
            ))
      ],
    ));

    rst.add(Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Left Border:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        buildRowWithHeaderText(
            headerText: "Width",
            actionWidget: Expanded(
              child: Slider(
                value: shape.borders.left.width,
                onChanged: (value) {
                  setState(() {
                    updateCurrentShape(shape.copyWith(
                        borders: shape.borders.copyWith(
                            left: shape.borders.left.copyWith(width: value))));
                  });
                },
                min: 0,
                max: 20,
                divisions: 20,
              ),
            )),
        buildRowWithHeaderText(
            headerText: "Color",
            actionWidget: BottomSheetColorPicker(
              currentColor: shape.borders.left.color,
              valueChanged: (value) {
                setState(() {
                  DynamicBorderSide newBorder = DynamicBorderSide(
                    width: shape.borders.left.width,
                    color: value,
                  );
                  updateCurrentShape(shape.copyWith(
                      borders: shape.borders.copyWith(left: newBorder)));
                });
              },
            )),
        buildRowWithHeaderText(
            headerText: "Gradient",
            actionWidget: BottomSheetGradientPicker(
              currentGradient: shape.borders.left.gradient,
              valueChanged: (value) {
                setState(() {
                  DynamicBorderSide newBorder = DynamicBorderSide(
                    width: shape.borders.left.width,
                    color: shape.borders.left.color,
                    gradient: value,
                  );
                  updateCurrentShape(shape.copyWith(
                      borders: shape.borders.copyWith(left: newBorder)));
                });
              },
            ))
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
              shapeSize = Size(
                  shapeSize.width.clamp(shapeMinimumSize, double.infinity),
                  shapeSize.height.clamp(shapeMinimumSize, double.infinity));
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

class StackDividerPainter extends CustomPainter {
  int xDivisions;
  int yDivisions;
  bool showBorder;

  StackDividerPainter(
      {@required this.xDivisions,
      @required this.yDivisions,
      this.showBorder = true});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5;
    double xDashDivisions = size.width / dashWidth * 0.5;
    double yDashDivisions = size.height / dashWidth * 0.5;

    final paint = Paint();
    paint.color = Colors.grey.withOpacity(0.6);

    int strokeWidthInv = xDivisions > yDivisions ? xDivisions : yDivisions;
    double strokeWidth = min(10.0 / strokeWidthInv, 1);
    paint.strokeWidth = strokeWidth;

    for (int i = 1; i < yDivisions; i++) {
      double startX = 0;
      for (int dashi = 0; dashi < xDashDivisions; dashi++) {
        canvas.drawLine(
            Offset(startX, size.height * i / yDivisions),
            Offset(startX + dashWidth, size.height * i / yDivisions)
                .clamp(Offset.zero, Offset(size.width, size.height)),
            paint);
        final space = 2 * dashWidth;
        startX += space;
      }
    }
    for (int i = 1; i < xDivisions; i++) {
      double startY = 0;
      for (int dashi = 0; dashi < yDashDivisions; dashi++) {
        canvas.drawLine(
            Offset(size.width * i / xDivisions, startY),
            Offset(size.width * i / xDivisions, startY + dashWidth)
                .clamp(Offset.zero, Offset(size.width, size.height)),
            paint);
        final space = 2 * dashWidth;
        startY += space;
      }
    }
    for (int i = 1; i <= 2 * xDivisions - 1; i++) {
      for (int j = 1; j <= 2 * yDivisions - 1; j++) {
        canvas.drawCircle(
            Offset(size.width * i / (2 * xDivisions),
                size.height * j / (2 * yDivisions)),
            strokeWidth * 1.6,
            paint);
      }
    }

    if (showBorder) {
      //Paint dashed border
      final borderPaint = Paint();
      borderPaint.color = Colors.black;
      borderPaint.strokeWidth = 0.5;
      double startX = 0, startY = 0;
      for (int dashi = 0; dashi < size.width / (2 * dashWidth); dashi++) {
        if (startX + dashWidth <= size.width) {
          canvas.drawLine(
              Offset(startX, 0), Offset(startX + dashWidth, 0), borderPaint);
          canvas.drawLine(Offset(startX, size.height),
              Offset(startX + dashWidth, size.height), borderPaint);
          startX += 2 * dashWidth;
        } else {
          canvas.drawLine(
              Offset(startX, 0), Offset(size.width, 0), borderPaint);
          canvas.drawLine(Offset(startX, size.height),
              Offset(size.width, size.height), borderPaint);
        }
      }
      for (int dashj = 0; dashj < size.height / (2 * dashWidth); dashj++) {
        if (startY + dashWidth <= size.height) {
          canvas.drawLine(
              Offset(0, startY), Offset(0, startY + dashWidth), borderPaint);
          canvas.drawLine(Offset(size.width, startY),
              Offset(size.width, startY + dashWidth), borderPaint);
          startY += 2 * dashWidth;
        } else {
          canvas.drawLine(
              Offset(0, startY), Offset(0, size.height), borderPaint);
          canvas.drawLine(Offset(size.width, startY),
              Offset(size.width, size.height), borderPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
