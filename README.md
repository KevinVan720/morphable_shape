# morphable_shape

A Flutter package for creating various shapes that are responsive
and can morph between each other.

Notice: This class uses the [dimension](https://pub.dev/packages/dimension) package but only the px and percent units are respected since ShapeBorder has no access to the build context and the screen size.

## Getting Started

First, you need to create a ShapeBorder instance. The responsive feature means that
you can have a single ShapeBorder instance that adapts to different sizes without you calculating the desired dimensions. For example, the following
code will give you a rounded rectangle border with a 60 px circular radius at the top left corner and a (60 px, 10%) elliptical corner at the bottom right corner.
(for more information of how to use the Length class, see [dimension](https://pub.dev/packages/dimension)).
```dart
ShapeBorder rectangle=RectangleShapeBorder(
    borderRadius: DynamicBorderRadius.only(
    topLeft: DynamicRadius.circular(10.toPXLength),
    bottomRight: DynamicRadius.elliptical(60.0.toPXLength, 10.0.toPercentLength))
    );
```

You can create a ShapeBorder that gets used by the Material widget or the ClipPath widget which perform the shape clipping.

```dart
Widget widget=Material(
    shape: rectangle,
    clipBehavior: Clip.antiAlias,
    child: Container()
    );
```

Or you can use it in a ShapeDecoration and provide it to the Container/DecoratedBox widget:
```dart
Decoration decoration = ShapeDecoration(shape: rectangle);
Widget widget = Container(
decoration: decoration
);
```

This package also has the **DecoratedShadowedShape** widget which lets you define inset shadows which Flutter does not support right now:
```dart
Widget widget = DecoratedShadowedShape(
    shape: shape,
    shadows: shadows,
    insetShadows: insetShadows,
    decoration: decoration,
    child: child
    );
```

You can run the example app to create a local shape editing tool to see the various shapes supported by this package (also hosted online at [https://fluttershape.com/](https://fluttershape.com/)).

## DynamicBorderSide

The DynamicBorderSide is an extension to the built-in BorderSide class. It supports gradient filling in addtion to single color filling. It also supports painting partially by specifing the begin, end and offset parameters (e.g. paint only the first half of the border side). You can change the strokeJoin and strokeCap paramter as well.

This class is used to configure how the borders are painted with different shapes.

```dart
DynamicBorderSide(
    style: BorderStyle.solid,
    width: 1,
    color: Colors.red,
    gradient: LinearGradient(colors:[Colors.red, Colors.blue]),
    begin: 0.toPercentLength,
    end: 100.toPercentLength,
    offset: 0.toPercentLength,
    strokeJoin: StrokeJoin.miter,
    strokeCap: StrokeCap.round,
);
```

## Supported Shapes

Currently supported shape borders are:

### RectangleShapeBorder
The most powerful and commonly used one should be the RectangleShapeBorder class. It allows to you configure each corner of the rectangle individually or at once.
It also automatically scales all sides so that they don’t overlap (just like what CSS does). The RectangleShapeBorder supports four different corner styles:
```dart
enum CornerStyle{
  rounded,
  concave,
  straight,
  cutout,
}
```

You can configure the corner styles at once or individually:
```dart
var cornerStyles=RectangleCornerStyles.all(CornerStyle.rounded);
cornerStyles=RectangleCornerStyles.only(
topLeft: CornerStyle.rounded, 
bottomRight: CornerStyle.concave
);
```

You can also specify the border width, color (or gradient) using the
DynamicBorderSide class:
```dart
var border=DynamicBorderSide(
width: 10,
gradient: LinearGradient(colors:[Colors.red, Colors.green]),
);
```

Now you get a fully fledged rectangle:
```
ShapeBorder rectangle=RectangleShapeBorder(
borderRadius:
        const DynamicBorderRadius.all(DynamicRadius.circular(Length(100))),
cornerStyles: cornerStyles,
border: border,
);
```

You can make a triangle, a diamond, a trapezoid, or even an arrow shape by just using the RectangleShapeBorder class and providing the right corner style and border radius.

![rectangle](https://i.imgur.com/I0jXJu2.png)

### CircleShapeBorder

CircleShapeBorder gives you a circle. Simple as that.

## RoundedRectangleShapeBorder
If you use the RoundedRectangleShapeBorder class, then the four border sides can be configured individually. The four border sides can be styled independently or at once, similar to what CSS offers:

```dart
var borders=RectangleBorderSides.all(DynamicBorderSide.none);
borders=RectangleBorderSides.symmetric(
horizontal: DynamicBorderSide(
width: 10,
color: Colors.blue,
));
borders=RectangleBorderSides.only(
top: DynamicBorderSide(
width: 10,
gradient: LinearGradient(colors:[Colors.red, Colors.green]),
));
```

Then you have:
```dart
ShapeBorder shapeBorder=RoundedRectangleShapeBorder({
    borderRadius: DynamicBorderRadius.all(DynamicRadius.circular(Length(100))),
    borderSides: borders,
  });
```
Below are some border designs using this class. This class is very similar to what CSS
offers and is a combination of the BoxBorder and RoundedRectangleBorder class that Flutter
offers.

![round_rectangle](https://i.imgur.com/Gfh5zxu.png)

### PolygonShapeBorder
PolygonShapeBorder supports changing the number of sides as well as corner radius and corner style:
```dart
PolygonShapeBorder(
sides:6,
cornerRadius: 10.toPercentLength,
cornerStyle: CornerStyle.rounded
)
```
![polygon](https://i.imgur.com/pzADQHO.png)

### StarShapeBorder
The StarShapeBorder allows you to change the number of corners, the inset, the border radius, the border style, the inset radius, and the inset style.

```dart
StarShapeBorder(
corners: 5,
inset: 50.toPercentLength,
cornerRadius: 0.toPXLength,
cornerStyle: CornerStyle.rounded,
insetRadius: 0.toPXLength,
insetStyle: CornerStyle.rounded
)
```
![star](https://i.imgur.com/00JT5jK.png)

### ArcShapeBorder, ArrowShapeBorder, BubbleShapeBorder, TrapezoidShapeBorder, TriangleShapeBorder
These shape borders are also supported and responsive. Check out their constructors to see how to make them.

![various](https://i.imgur.com/qDK8sBf.png)

### PathShapeBorder
Accepts a DynamicPath instance to draw a custom path border. Right now only straight line and cubic Bezier curves are supported. Arcs need to be translated to cubic Beziers first. In the future I may let this class accept close SVG path as well.

## Shape Morphing

Every shape in this package can be morphed into one another, including the border side(s). Hence the name of this package. To morph between two shapes you first need to create a ShapeBorderTween:
```dart
MorphableShapeBorderTween shapeBorderTween =
        MorphableShapeBorderTween(begin: beginShapeBorder, end: endShapeBorder);
```

Then you can get the intermediate shapes at progress **t**(from 0 to 1) by calling:

```dart
ShapeBorder intermediate=shapeBorderTween.lerp(t);
```

For an explanation and demonstration of the morphing algorithm, take a look at this
[Medium post](https://kevinvan.medium.com/creating-morphable-shapes-in-flutter-a-complete-rewrite-ac899bfe4222).

Below are some showcases of the shape morphing process. Most shapes can be morphed in a natural fashion.

![morph](https://i.imgur.com/Ic9xJeN.gif)

![morph2](https://i.imgur.com/j7k4wL6.gif)

There are three morph methods to choose when you create your tween.
```dart
MorphableShapeBorderTween shapeBorderTween =
        MorphableShapeBorderTween(begin: startBorder, end: endBorder, 
        method: MorphMethod.auto);
```
The MorphMethod.weighted tries to use as little control
points as possible to do the morphing and takes into account the length of each side of a shape. The MorphMethod.unweighted uses more points  
but do not utilize the length information. The MorphMethod.auto will choose either
one of the two methods based on some geometric criteria to make the morphing
process to look more natural. The auto method generally works well, but you can
try other ones if the morphing looks weird.

Shapes with the same geometry can be morphed faster and in a more consistent way. For example, rectangles and rounded rectangles, or polygons with the same number of sides. For other shapes, the morphing takes more time and may not look great especially for two very distinct shapes.

## Shape Serialization

Every shape in this package supports serialization. If you have designed some shape you like, just call toJson() on it. Then you can reuse it by writting.

```dart
Shape shape=RoundedRectangleShape();
String jsonStr=json.encode(shape.toJson());
Shape shapeDecoded=parseShape(json.decode(jsonStr));
```

## Decorated Shadowed Shape
You can use the DecoratedShadowedShape widget to add shadow and inset shadow to your widget.
```dart
DecoratedShadowedShape(
      shape: shape,
      shadows: shadows,
      insetShadows: insetShadows,
      decoration: decoration,
      child: child);
```
This will render the following component from bottom to top: shadows, decoration, inset shadows, child, shape border.

The ShapeShadow is very similar to the BoxShadow class but supports gradient filling:
```dart
const ShapeShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    this.spreadRadius = 0.0,
    this.gradient,
  })
```

If you want implicit animation for this widget, use the AnimatedDecoratedShadowedShape.

The [animated_styled_widget](https://pub.dev/packages/animated_styled_widget) has many exmaples using the DecoratedShadowedShape widget.

## A Shape Editing Tool

As I mentioned before, the example app in this package is a shape editing tool for
you to quickly design the shape you want and generate the corresponding code. Below are
some screenshots of the interfaces of this tool. I put about equal amount of effort
into developing this tool compared to developing this package so I strongly recommend you
to check it out. You can either build it locally or visit:
[https://fluttershape.com/](https://fluttershape.com/).

![interface](https://i.imgur.com/MhMABhT.png)
![interface2](https://i.imgur.com/cLyVdrW.png)
![interface3](https://i.imgur.com/ZaJGegQ.png)
![interface4](https://i.imgur.com/oXCRr02.png)
![interface5](https://i.imgur.com/aRRjDdh.png)