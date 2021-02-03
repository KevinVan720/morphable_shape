# morphable_shape

A Flutter package for creating various shapes that are responsive 
and can morph betweem each other.

## Getting Started

Shapes that are responsive (using px or percentage as length measure) and
able to morph between each other. You can use the shape to create a shapeBorder
that gets used by the Material widget or ClipPath.

```
var border=MorphableShapeBorder(
shape: ...,
borderColor: ...,
borderWidth: ...,
);

...

Material(
shape: shapeBorder,
clipBehavior: Clip.antiAlias,
child: ...
);
``` 

The responsive feature means you can have a single shape instance that adapts to different window sizes 
without you calculating the desired dimensions. For example:
```
var shape=ArrowShape(
 side: ShapeSide.right,
 arrowHeight: const Length(25, unit: LengthUnit.percent),
 tailWidth: const Length(40, unit: LengthUnit.px)
);
```
will create an arrow shape pointing to the right, with a arrow height that is 25% of the bounding box's width
and a tail with a fixed width 40px. For more information of how to use the Length class, see [length_unit](https://pub.dev/packages/length_unit).

## Supported Shapes

Currently supported shapes are:

```
Arc
Arrow
Bubble
Circle
Path
Polygon
Rectangle
Star
Trapezoid
Triangle
```

Each shape class has various parameters to modify (like corner radius and corner style for rectangle, polygon and star). 
You can play with the shape editor example to get the shape you want. 

## Shape Morphing

Every shape in this package can be gracefully morphed into another shape. By creating a ShapeBorderTween:
```
MorphableShapeBorder startBorder;
MorphableShapeBorder endBorder;

startBorder = MorphableShapeBorder(
        shape: startShape, borderColor: Colors.redAccent, borderWidth: 1);
endBorder = MorphableShapeBorder(
        shape: endShape, borderColor: Colors.redAccent, borderWidth: 1);

MorphableShapeBorderTween shapeBorderTween =
        MorphableShapeBorderTween(begin: startBorder, end: endBorder);
```

you can get the intermediate shapes at progress t by calling:

```
shapeBorderTween.lerp(t)
```

For an explanation and demonstration of the morphing capabilities, take a look at this
[Medium post](https://kevinvan.medium.com/creating-morphable-shapes-in-flutter-f17bcfecb0ed).

#Shape Serialization and Editing

Every shape in this package can be serialized and deserialized. So if you have designed some shape you like, just call toJson()
on it can then you can reuse it wherever you want. 

For you to design the shape you want more easily, I have created the shape editing tool under the example/ folder 
(also at [http://fluttershape.com/](http://fluttershape.com/))