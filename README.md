# morphable_shape

A Flutter package for creating various shapes that are responsive
and can morph betweem each other.

Notice: Please always try to use the latest version of this package  
(which has null safety enabled). All future development will happen
there.

## Getting Started

First, you need to create a Shape instance. The responsive feature means  
you can have a single shape instance that adapts to different sizes
without you calculating the desired dimensions. For example, the following  
code will give you a rectangle with a 60 px circular radius at the top  
left corner and a (60 px, 10%) elliptical corner at the bottom right corner.  
(for more information of how to use the Length class, see  
[length_unit](https://pub.dev/packages/length_unit)).
```dart
Shape rectangle=RectangleShape(
borderRadius: DynamicBorderRadius.only(
topLeft: DynamicRadius.circular(10.toPXLength),
bottomRight: DynamicRadius.elliptical(60.0.toPXLength, 10.0.toPercentLength))
);
```

You can use the shape to create a shapeBorder that gets used by the Material widget  
or the ClipPath widget which perform the shape clipping.

```dart
var border=MorphableShapeBorder(
shape: rectangle,
);

var widget=Material(
shape: shapeBorder,
clipBehavior: Clip.antiAlias,
child: Container()
);
``` 

You can run the example app to create a local shape editing tool to see the various  
shapes supported by this package.
(also hosted online at [https://fluttershape.com/](https://fluttershape.com/))

## Supported Shapes

Currently supported shapes are:

### RectangleShape
The most powerful and commonly used one should be the RectangleShape class.  
It allows to you configure each corner of the rectangle individually or at once.  
It also automatically scales all sides so that they don’t overlap (just like what CSS does).  
The RectangleShape supports four different corner styles:
```dart
enum CornerStyle{
  rounded,
  concave,
  straight,
  cutout,
}
```

You can configure the corner styles like this:
```dart
var cornerStyles=RectangleCornerStyles.all(CornerStyle.rounded);
cornerStyles=RectangleCornerStyles.only(
topLeft: CornerStyle.rounded, 
bottomRight: CornerStyle.concave
);
```

You can also specify the border with, color (or gradient) using the
DynamicBorderSide class:
```dart
var border=DynamicBorderSide(
width: 10.toPXWidth,
gradient: LinearGradient(colors:[Colors.red, Colors.green]),
);
```

Now you get a fully fledged rectangle:
```
Shape rectangle=RectangleShape(
borderRadius:
        const DynamicBorderRadius.all(DynamicRadius.circular(Length(100))),
cornerStyles: cornerStyles,
border: border,
);
```

You can make a triangle, a diamond, a trapezoid,  
or even an arrow shape by just using the RectangleShape  
class and providing the right corner style and radius.

![rectangle](https://i.imgur.com/I0jXJu2.png)

## RoundedRectangleShape
If you use the RoundedRectangleShape class, then the four border sides
can be configured individually. The four border sides can be styled  
independently or at once:
```dart
var borders=RectangleBorders.all(DynamicBorderSide.none);
borders=RectangleBorders.symmetric(
horizontal: DynamicBorderSide(
width: 10.toPercentWidth,
color: Colors.blue,
));
borders=RectangleBorders.only(
top: DynamicBorderSide(
width: 10.toPXWidth,
gradient: LinearGradient(colors:[Colors.red, Colors.green]),
));
```

Then you have:
```dart
Shape rect=RoundedRectangleShape({
    borderRadius: DynamicBorderRadius.all(DynamicRadius.circular(Length(100))),
    borders: borders,
  });
```
Below are some multi-colored border design using this class.

![round_rectangle](https://i.imgur.com/Gfh5zxu.png)

### CircleShape
CircleShape allows you to choose the start angle and sweep angle:
```dart
CircleShape(
startAngle: 0,
sweepAngle: 2*pi,
)
```
![circle](https://i.imgur.com/AYWNWXQ.png)

### PolygonShape
PolygonShape supports changing the number of sides as well as corner radius and corner style:
```dart
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
```dart
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

Every shape in this package can be gracefully morphed into another shape, including  
the border(s). By creating a ShapeBorderTween:
```dart
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

```dart
shapeBorderTween.lerp(t)
```

For an explanation and demonstration of the morphing capabilities, take a look at this
[Medium post](https://kevinvan.medium.com/creating-morphable-shapes-in-flutter-a-complete-rewrite-ac899bfe4222).

Below are some showcases of the shape morphing process. Most shapes can be morphed in a natural
and pixel-perfect fashion.
![morph](https://i.imgur.com/Ic9xJeN.gif)

![morph2](https://i.imgur.com/j7k4wL6.gif)


## Shape Serialization

Every shape in this package supports serialization.  
If you have designed some shape you like, just call toJson() on it.  
Then you can reuse it by calling Shape.fromJson(json).