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
Shape rectangle=RectangleShape(
borderRadius: DynamicBorderRadius.only(
topLeft: DynamicRadius.circular(10.toPXLength),
bottomRight: DynamicRadius.elliptical(60.0.toPXLength, 10.0.toPercentLength))
);
```
will give you a rectangle with a 60 px circular radius at the top left corner and a (60 px, 10%) elliptical corner at the bottom right.  
For more information of how to use the Length class, see [length_unit](https://pub.dev/packages/length_unit).

For you to design the shape you want more easily, I have created the shape editing tool under the example/ folder
(also at [https://fluttershape.com/](https://fluttershape.com/))

## Supported Shapes

Currently supported shapes are:

### RectangleShape
The most powerful and commonly used one should be the RectangleShape class.  
It allows to you configure each corner of the rectangle individually or at once.  
If two radii overlap at one of the sides of the rectangle (like 60% and 50%),  
it automatically scales both sides so that they don’t overlap (just like what CSS does).  
The RenctangleShape also supports other corner styles:
```
enum CornerStyle{
  rounded,
  concave,
  straight,
  cutout,
}
Shape rectangle=RectangleShape(
topLeft: CornerStyle.rounded,
topRight: CornerStyle.concave,
bottomLeft: CornerStyle.cutout,
bottomRight: CornerStyle.straight,
borderRadius: DynamicBorderRadius.all(
DynamicRadius.circular(50.toPXLength)
);
```

You can make a triangle, a diamond, a trapezoid,  
or even an arrow shape by just using the RectangleShape  
class and providing the right corner style and radius.

![rectangle](https://i.imgur.com/I0jXJu2.png)

### CircleShape
CircleShape allows you to choose the start angle and sweep angle:
```
CircleShape(
startAngle: 0,
sweepAngle: 2*pi,
)
```
![circle](https://i.imgur.com/AYWNWXQ.png)

### PolygonShape
PolygonShape supports changing the number of sides as well as corner radius and corner style:
```
PolygonShape(
sides:6,
cornerRadius: 10.toPercentLength,
cornerStyle: CornerStyle.rounded
)
```
![polygon](https://i.imgur.com/pzADQHO.png)
### StarShape
The StarShape allows you to change the number of corners,  
the inset, the border radius, the border style, the inset  
radius, and the inset style.
```
StarShape(
corners: 5,
inset: 50.toPercentLength,
cornerRadius: 0.toPXLength,
cornerStyle: CornerStyle.rounded,
insetRadius: 0.toPXLength,
insetStyle: CornerStyle.rounded
)
```
![star](https://i.imgur.com/00JT5jK.png)

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
[Medium post](https://kevinvan.medium.com/creating-morphable-shapes-in-flutter-a-complete-rewrite-ac899bfe4222).

![morph](https://i.imgur.com/cwpoj0Z.gifv)

## Shape Serialization

Every shape in this package supports serialization.  
If you have designed some shape you like, just call toJson() on it.  
Then you can reuse it by calling Shape.fromJson(json).