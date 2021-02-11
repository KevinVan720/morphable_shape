import 'package:flutter/material.dart';
import 'morphable_shape_border.dart';
import 'dart:math';

///Maybe used in the future to help editing DynamicPath
enum NodeControlMode {
  none,
}

///A single point with two possible control points
class DynamicNode {
  Offset position;
  Offset? prev;
  Offset? next;

  DynamicNode({required this.position, this.prev, this.next});

  DynamicNode.fromJson(Map<String, dynamic> map)
      : position = parseOffset(map["pos"]) ?? Offset(0, 0),
        prev = parseOffset(map["prev"]),
        next = parseOffset(map["next"]);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {};
    rst["pos"] = position.toJson();
    rst.updateNotNull("prev", prev?.toJson());
    rst.updateNotNull("next", next?.toJson());
    return rst;
  }
}

///A Bezier path with either straight line or cubic Bezier line
class DynamicPath {
  static double boxBoundingTolerance = 0.01;
  static int defaultPointPrecision = 2;

  Size size;
  List<DynamicNode> nodes;

  Path? _path;

  DynamicPath({required this.size, required this.nodes}) {
    ///Some control points may lie outside the bounding rect, in this case,
    ///I break the involved Bezier line segment into two so that the new control points may be inside
    ///the bounding box or move closer to it. Repeat this process to get an optimal result
    ///max 20 times trial, 1% tolerance
    double tolerance = min(size.width, size.height) * boxBoundingTolerance;
    Rect bound = Rect.fromLTRB(-tolerance, -tolerance, size.width + tolerance,
        size.height + tolerance);
    int outlierIndex = getOutlierIndex(bound: bound);
    int iteration = 0;

    while (outlierIndex != -1 && iteration < 20) {
      int splitIndex = outlierIndex;
      if (!bound.contains(nodes[outlierIndex].prev ?? Offset.zero)) {
        splitIndex = (outlierIndex - 1) % nodes.length;
      }
      int nextIndex = (splitIndex + 1) % nodes.length;
      List<Offset> controlPoints = getNextPathControlPointsAt(splitIndex);

      List<Offset> splitControlPoints;
      if (controlPoints.length >= 4) {
        splitControlPoints = splitCubicAt(0.5, controlPoints);
        nodes[splitIndex].next = splitControlPoints[1];
        nodes[nextIndex].prev = splitControlPoints[5];
        nodes.insert(
            nextIndex,
            DynamicNode(
                position: splitControlPoints[3],
                prev: splitControlPoints[2],
                next: splitControlPoints[4]));
      }
      outlierIndex = getOutlierIndex(bound: bound);
      iteration++;
    }

    ///Effectively force the points and control points within the bounding rect
    for (int index = 0; index < nodes.length; index++) {
      moveNodeBy(index, Offset.zero);
      nodes[index].position =
          nodes[index].position.roundWithPrecision(defaultPointPrecision);
      nodes[index].prev =
          nodes[index].prev?.roundWithPrecision(defaultPointPrecision);
      nodes[index].next =
          nodes[index].next?.roundWithPrecision(defaultPointPrecision);
    }

    /// combine points that lie very close
    cleanOverlappingNodes();
  }

  int getOutlierIndex({required Rect bound}) {
    int outlierIndex = -1;
    for (int index = 0; index < nodes.length; index++) {
      if (!bound.contains(nodes[index].position) ||
          !bound.contains(nodes[index].prev ?? Offset.zero) ||
          !bound.contains(nodes[index].next ?? Offset.zero)) {
        outlierIndex = index;
        break;
      }
    }
    return outlierIndex;
  }

  void cleanOverlappingNodes() {
    if (nodes.isNotEmpty) {
      List<DynamicNode> newNodes = [nodes[0]];
      for (int i = 0; i < nodes.length; i++) {
        if ((nodes[i].position - newNodes.last.position).distance <
            boxBoundingTolerance * size.shortestSide) {
          newNodes.last.next = nodes[i].next;
        } else if (i == nodes.length - 1 &&
            (nodes[i].position - newNodes.first.position).distance <
                boxBoundingTolerance * size.shortestSide) {
          newNodes.first.prev = nodes[i].prev;
        } else {
          newNodes.add(nodes[i]);
        }
      }
      nodes = newNodes;
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {};
    rst["size"] = size.toJson();
    rst["nodes"] = nodes.map((e) => e.toJson()).toList();
    return rst;
  }

  Offset getCenterOfMass() {
    Offset center = Offset.zero;
    nodes.forEach((element) {
      center += element.position;
    });
    return center / nodes.length.toDouble();
  }

  void rotate(double angle) {
    Offset center = getCenterOfMass();
    nodes.forEach((element) {
      element.position =
          element.position.rotateAround(pivot: center, angle: angle);
      if (element.prev != null) {
        element.prev = element.prev!.rotateAround(pivot: center, angle: angle);
      }
      if (element.next != null) {
        element.next = element.next!.rotateAround(pivot: center, angle: angle);
      }
    });
  }

  void shift(Offset shift) {
    nodes.forEach((element) {
      element.position = element.position + shift;
      if (element.prev != null) {
        element.prev = element.prev! + shift;
      }
      if (element.next != null) {
        element.next = element.next! + shift;
      }
    });
  }

  void resize(Size newSize) {
    nodes.forEach((element) {
      element.position = element.position
          .scale(newSize.width / size.width, newSize.height / size.height);
      element.prev = element.prev
          ?.scale(newSize.width / size.width, newSize.height / size.height);
      element.next = element.next
          ?.scale(newSize.width / size.width, newSize.height / size.height);
    });
    size = newSize;
  }

  DynamicNode getNodeWithControlPoints(int index) {
    DynamicNode newNode = DynamicNode(
        position: nodes[index].position,
        prev: nodes[index].prev,
        next: nodes[index].next);

    if (newNode.prev == null) {
      int prevIndex = (index - 1) % nodes.length;
      newNode.prev =
          newNode.position + (nodes[prevIndex].position - newNode.position) / 3;
    }
    if (newNode.next == null) {
      int nextIndex = (index + 1) % nodes.length;
      newNode.next =
          newNode.position + (nodes[nextIndex].position - newNode.position) / 3;
    }

    return newNode;
  }

  void moveNodeTo(int index, Offset offset) {
    DynamicNode node = nodes[index];
    Offset diff =
        (offset - node.position).roundWithPrecision(defaultPointPrecision);
    node.position = offset;
    node.position =
        node.position.clamp(Offset.zero, Offset(size.width, size.height));
    if (node.prev != null) {
      node.prev = node.prev! + diff;
      node.prev =
          node.prev!.clamp(Offset.zero, Offset(size.width, size.height));
    }
    if (node.next != null) {
      node.next = node.next! + diff;
      node.next =
          node.next!.clamp(Offset.zero, Offset(size.width, size.height));
    }
  }

  void moveNodeBy(int index, Offset offset,
      {NodeControlMode mode = NodeControlMode.none}) {
    DynamicNode node = nodes[index];
    Offset avalOffset = ((node.position + offset)
                .clamp(Offset.zero, Offset(size.width, size.height)) -
            node.position)
        .roundWithPrecision(defaultPointPrecision);
    /*
    if (node.prev != null) {
      Offset avalOffset2=availableOffset(node.prev!, offset);
      print("aval prev: "+avalOffset2.toString());
      avalOffset=avalOffset2.distance<avalOffset.distance ? avalOffset2 : avalOffset;
    }
    if (node.next != null) {
      Offset avalOffset2=availableOffset(node.next!, offset);
      print("aval next: "+avalOffset2.toString());
      avalOffset=avalOffset2.distance<avalOffset.distance ? avalOffset2 : avalOffset;
    }
    */
    node.position += avalOffset;
    node.position =
        node.position.clamp(Offset.zero, Offset(size.width, size.height));

    if (node.prev != null) {
      node.prev = node.prev! + avalOffset;
      node.prev =
          node.prev!.clamp(Offset.zero, Offset(size.width, size.height));
    }
    if (node.next != null) {
      node.next = node.next! + avalOffset;
      node.next =
          node.next!.clamp(Offset.zero, Offset(size.width, size.height));
    }

    /*
    else{
      if(node.prev!=null || node.next!=null) {
        if(node.prev==null) {
          node.prev=node.position-(node.next!-node.position);
        }
        if(node.next==null) {
          node.next=node.position-(node.prev!-node.position);
        }
        Offset prevAvail=(node.prev!+offset).clamp(Offset.zero, Offset(size.width, size.height))-node.prev!;
        Offset nextAvail=(node.next!+offset).clamp(Offset.zero, Offset(size.width, size.height))-node.next!;
        if(prevAvail!=offset || nextAvail!=offset) {
          Offset actualOffset=prevAvail.distance<nextAvail.distance? prevAvail : nextAvail;
          if(actualOffset==prevAvail) {
            node.prev=node.prev!+actualOffset;
            node.next=node.position-(node.prev!-node.position);
          }else{
            node.next=node.next!+actualOffset;
            node.prev=node.position-(node.next!-node.position);
          }
        }else{
          node.prev=node.prev!+offset;
          node.next=node.position-(node.prev!-node.position);
          //node.next=node.next!+offset;
        }
      }
    }
*/
  }

  ///Reserved for future more editing mode
  /*
  Offset? getIntersectPoint(Offset x1, Offset x2, Offset y1, Offset y2) {
    Offset s1, s2;
    s1=x2-x1;
    s2=y2-y1;
    double s,t;
    s=(-s1.dy*(x1.dx-y1.dx)+s1.dx*(x1.dy-y1.dy))/(-s2.dx*s1.dy+s1.dx*s2.dy);
    t=(-s2.dy*(x1.dx-y1.dx)+s2.dx*(x1.dy-y1.dy))/(-s2.dx*s1.dy+s1.dx*s2.dy);

    if(s>=0 && s<=1 && t>=0 && t<=1) {
      return x1+s1*t;
    }
    return null;
  }

  Offset availableOffset(Offset start, Offset offset) {
    if(offset==Offset.zero) return offset;
    Offset? inter1, inter2;
    if(offset.dx<=0) {
      inter1=getIntersectPoint(start, start+offset, Offset.zero, Offset(0, size.height));
    }else{
      inter1=getIntersectPoint(start, start+offset, Offset(size.width,0), Offset(size.width, size.height));
    }

    if(offset.dy<=0) {
      inter2=getIntersectPoint(start, start+offset, Offset.zero, Offset(size.width, 0));
    }else{
      inter2=getIntersectPoint(start, start+offset, Offset(0,size.height), Offset(size.width, size.height));
    }

    if(inter1!=null) {
      //print(inter1);
      return inter1-start;
    }
    if(inter2!=null) {
      //print(inter2);
      return inter2=start;
    }
    return offset;
  }
  */

  ///move either one of the control point of the node to offset
  void moveNodeControlTo(int index, bool prev, Offset offset,
      {NodeControlMode mode = NodeControlMode.none}) {
    DynamicNode node = nodes[index];
    if (prev) {
      node.prev = offset.roundWithPrecision(defaultPointPrecision);
      node.prev =
          node.prev!.clamp(Offset.zero, Offset(size.width, size.height));
    } else {
      node.next = offset.roundWithPrecision(defaultPointPrecision);
      node.next =
          node.next!.clamp(Offset.zero, Offset(size.width, size.height));
    }
  }

  ///Get the necessary points to draw the straight or cubic Bezier path at index
  List<Offset> getNextPathControlPointsAt(int index) {
    List<Offset> rst = [];
    int nextIndex = (index + 1) % nodes.length;
    Offset? control1 = nodes[index].next;
    Offset? control2 = nodes[nextIndex].prev;
    if (control1 != null && control2 != null) {
      rst.add(nodes[index].position);
      rst.add(control1);
      rst.add(control2);
      rst.add(nodes[nextIndex].position);
    } else if (control1 != null && control2 == null) {
      Offset tempControl2 = nodes[nextIndex].position +
          (nodes[index].position - nodes[nextIndex].position) / 3;
      rst.add(nodes[index].position);
      rst.add(control1);
      rst.add(tempControl2);
      rst.add(nodes[nextIndex].position);
    } else if (control1 == null && control2 != null) {
      Offset tempControl1 = nodes[index].position +
          (nodes[nextIndex].position - nodes[index].position) / 3;
      rst.add(nodes[index].position);
      rst.add(tempControl1);
      rst.add(control2);
      rst.add(nodes[nextIndex].position);
    } else {
      rst.add(nodes[index].position);
      rst.add(nodes[nextIndex].position);
    }
    return rst;
  }

  ///convert this to a Path
  Path getPath(Size newSize) {
    if (newSize == size && _path != null) {
      return _path!;
    } else {
      resize(newSize);
      Path path = Path();
      if (nodes.isNotEmpty) {
        path.moveTo(nodes[0].position.dx, nodes[0].position.dy);
      }
      for (int i = 0; i < nodes.length; i++) {
        List<Offset> controlPoints = getNextPathControlPointsAt(i);
        if (controlPoints.length == 4) {
          path
            ..cubicTo(
                controlPoints[1].dx,
                controlPoints[1].dy,
                controlPoints[2].dx,
                controlPoints[2].dy,
                controlPoints[3].dx,
                controlPoints[3].dy);
        } else {
          path..lineTo(controlPoints[1].dx, controlPoints[1].dy);
        }
      }

      _path = path;
      return path;
      //final Matrix4 matrix4 = Matrix4.identity();
      //matrix4.scale(newSize.width / size.width, newSize.height / size.height);
      //return path.transform(matrix4.storage);
    }
  }

  ///convert this to a list of Paths
  ///possible for multiple border color and width?
  List<Path> getPaths(
      Size newSize, List<Color> borderColors, DynamicEdgeInsets? borderInsets) {
    int pathLength = nodes.length;
    if (borderColors.length < pathLength) {
      int diff = pathLength - borderColors.length;
      for (int i = 0; i < diff; i++) {
        borderColors.add(Colors.black);
      }
    } else if (borderColors.length > pathLength) {
      int diff = pathLength - borderColors.length;
      for (int i = 0; i < diff; i++) {
        borderColors.removeLast();
      }
    }

    Rect originalRect=getPath(newSize).getBounds();
    double top = 0, bottom = 0, left = 0, right = 0;
    if (borderInsets != null) {
      top = borderInsets.top
              ?.toPX(constraintSize: originalRect.height)
              .clamp(0, originalRect.height) ??
          0;
      bottom = borderInsets.bottom
              ?.toPX(constraintSize: originalRect.height)
              .clamp(0, originalRect.height) ??
          0;
      left = borderInsets.left
              ?.toPX(constraintSize: originalRect.width)
              .clamp(0, originalRect.width) ??
          0;
      right = borderInsets.right
              ?.toPX(constraintSize: originalRect.width)
              .clamp(0, originalRect.width) ??
          0;
      if (top + bottom > originalRect.height) {
        double ratio = top / (top + bottom);
        top =  ratio * originalRect.height;
        bottom = (1 - ratio) * originalRect.height;
      }
      if (left + right > originalRect.width) {
        double ratio = left / (left + right);
        left = ratio * originalRect.width;
        right = (1 - ratio) * originalRect.width;
      }
    }

    List<Path> rst = [];

    DynamicPath newPath = DynamicPath(size: size, nodes: []);
    nodes.forEach((element) {
      newPath.nodes.add(DynamicNode(
          position: element.position, prev: element.prev, next: element.next));
    });
    newPath.resize(
        Size(originalRect.width - left - right, originalRect.height - top - bottom));
    //Offset diff=getCenterOfMass()-newPath.getCenterOfMass();
    newPath.shift(Offset(originalRect.left+left, originalRect.top+top));
    //newPath.shift(Offset(left, top));

    for (int i = 0; i < pathLength; i++) {
      DynamicNode nextNode = nodes[(i + 1) % pathLength];
      DynamicPath borderPath = DynamicPath(size: size, nodes: []);
      borderPath.nodes
          .add(DynamicNode(position: nodes[i].position, next: nodes[i].next));
      borderPath.nodes
          .add(DynamicNode(position: nextNode.position, prev: nextNode.prev));
      DynamicNode nextInnerNode = newPath.nodes[(i + 1) % pathLength];
      borderPath.nodes.add(DynamicNode(
          position: nextInnerNode.position, next: nextInnerNode.prev));
      borderPath.nodes.add(DynamicNode(
          position: newPath.nodes[i].position, prev: newPath.nodes[i].next));
      rst.add(borderPath.getPath(size));
    }

    final Matrix4 matrix4 = Matrix4.identity();
    matrix4.scale(newSize.width / size.width, newSize.height / size.height);
    return rst.map((e) => e.transform(matrix4.storage)).toList();
  }

  /*
  double getInnerDirection(Offset start, double direction) {
    if (!this
        .getPath(size)
        .contains((start + Offset.fromDirection(direction, 0.1)))) {
      return direction + pi;
    }
    return direction;
  }

  DynamicNode getInsetNodeAt(
      int index, bool isPrev, BorderSide prevSide, BorderSide nextSide) {
    DynamicNode node = getNodeWithControlPoints(index);
    double middleDirection = ((node.prev! - node.position).direction +
            (node.next! - node.position).direction) /
        2;
/*
    double a1 = Offset.fromDirection(node.prev!.direction).dx;
    double a2 = Offset.fromDirection(node.prev!.direction).dy;
    double b1 = Offset.fromDirection(
            getInnerDirection(node.prev!, node.prev!.direction+pi/2),
            prevSide.width)
        .dx;
    double b2 = Offset.fromDirection(
            getInnerDirection(node.prev!, node.prev!.direction+pi/2),
            prevSide.width)
        .dy;
    double c1 = Offset.fromDirection(node.next!.direction).dx;
    double c2 = Offset.fromDirection(node.next!.direction).dy;
    double d1 = Offset.fromDirection(
            getInnerDirection(node.next!, node.next!.direction+pi/2),
            nextSide.width)
        .dx;
    double d2 = Offset.fromDirection(
            getInnerDirection(node.next!, node.next!.direction+pi/2),
            nextSide.width)
        .dy;

    double x1 = ((d2 - b2) * c1 - (d1 - b1) * c2) / (a2 * c1 - a1 * c2);

    print("x1: "+x1.toString());

    Offset newPos = node.position +
        Offset.fromDirection(node.prev!.direction) * x1 +
        Offset.fromDirection(
            getInnerDirection(node.position, node.prev!.direction),
            prevSide.width);

 */

    if (!this
        .getPath(size)
        .contains((node.position + Offset.fromDirection(middleDirection, 1)))) {
      middleDirection = middleDirection + pi;
    }

    Offset prevDistance = node.prev! - node.position;
    Offset nextDistance = node.next! - node.position;

    double inset = (prevSide.width + nextSide.width) / 2;

    if (prevSide.width > nextSide.width) {
      inset = prevSide.width -
          (prevDistance.distance) /
              (prevDistance.distance + nextDistance.distance) *
              (prevSide.width - nextSide.width);
    } else {
      inset = nextSide.width -
          (nextDistance.distance) /
              (prevDistance.distance + nextDistance.distance) *
              (nextSide.width - prevSide.width);
    }

    Offset newPos =
        node.position + Offset.fromDirection(middleDirection, inset);

    if (isPrev) {
      return DynamicNode(
        position: newPos,
        //prev: (node.next! - node.position) * 0.8 +
        //    node.position +
        //    Offset.fromDirection(middleDirection, nextSide.width)
      );
    } else {
      return DynamicNode(
        position: newPos,
        //next: (node.prev! - node.position) * 0.8 +
        //    node.position +
        //    Offset.fromDirection(middleDirection, prevSide.width)
      );
    }
  }
  */

  static double estimateCubicLength(List<Offset> controlPoints) {
    Offset x0 = controlPoints[0];
    Offset x1 = controlPoints[1];
    Offset x2 = controlPoints[2];
    Offset x3 = controlPoints[3];
    return ((x3 - x0).distance +
            (x1 - x0).distance +
            (x2 - x1).distance +
            (x3 - x2).distance) /
        2;
  }

  ///split a cubic Bezier path at parameter t
  static List<Offset> splitCubicAt(double t, List<Offset> controlPoints) {
    Offset x1 = controlPoints[0];
    Offset x2 = controlPoints[1];
    Offset x3 = controlPoints[2];
    Offset x4 = controlPoints[3];
    Offset x12, x23, x34, x123, x234, x1234;
    x12 = (x2 - x1) * t + x1;
    x23 = (x3 - x2) * t + x2;
    x34 = (x4 - x3) * t + x3;
    x123 = (x23 - x12) * t + x12;
    x234 = (x34 - x23) * t + x23;
    x1234 = (x234 - x123) * t + x123;
    return [x1, x12, x123, x1234, x234, x34, x4];
  }

  /*
  static Offset cubicOffsetAt(double t, List<Offset> controlPoints) {
    Offset x0 = controlPoints[0];
    Offset x1 = controlPoints[1];
    Offset x2 = controlPoints[2];
    Offset x3 = controlPoints[3];
    return x0 * (1 - t) * (1 - t) * (1 - t) +
        x1 * 3 * (1 - t) * (1 - t) * t +
        x2 * 3 * (1 - t) * t * t +
        x3 * t * t * t;
  }

  static double calculateCubicLength(List<Offset> controlPoints) {
    Offset last, current;
    last = cubicOffsetAt(0, controlPoints);
    int steps = 1000;
    double rst = 0.0;
    for (int i = 1; i <= steps; i++) {
      current = cubicOffsetAt(i / steps, controlPoints);
      rst += (current - last).distance;
      last = current;
    }
    return rst;
  }
  */

  double getPathLengthAt(int index) {
    List<Offset> points = getNextPathControlPointsAt(index);
    if (points.length == 4) {
      return estimateCubicLength(points);
    } else {
      return (points[1] - points[0]).distance;
    }
  }
}
