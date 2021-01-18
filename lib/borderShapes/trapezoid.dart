
import 'package:flutter/material.dart';

import '../MorphableShapeBorder.dart';

class TrapezoidShape extends Shape {

  final double inset;

  const TrapezoidShape({this.inset=0.5}) : assert(inset>=0.0 && inset<=1.0);

  TrapezoidShape.fromJson(Map<String, dynamic> map)
      :
        inset=map['inset'];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst={"name": this.runtimeType};
    rst["inset"]=inset;
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    List<DynamicNode> nodes = [];

    Size size=rect.size;

    nodes.add(DynamicNode(position: Offset(0,0)));
    nodes.add(DynamicNode(position: Offset(size.width,0)));
    nodes.add(DynamicNode(position: Offset(size.width*(1-inset/2), size.height)));
    nodes.add(DynamicNode(position: Offset(size.width*(inset/2), size.height)));

    return DynamicPath(size: size, nodes: nodes);
  }

  Path generatePath({double scale=1, Rect rect= const Rect.fromLTRB(0.0, 0.0, 0.0, 0.0)}) {

    Size size=rect.size;

    final Path path = new Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width*(1-inset/2), size.height);
    path.lineTo(size.width*(inset/2), size.height);
    path.close();

    return path;
  }
}
