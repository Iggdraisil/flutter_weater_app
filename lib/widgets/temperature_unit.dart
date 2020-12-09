import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WeatherInfoWidget extends StatefulWidget {
  WeatherInfoWidget({Key key, this.temperature}) : super(key: key);

  final double temperature;

  @override
  _WeatherInfoState createState() => _WeatherInfoState();
}

class _WeatherInfoState extends State<WeatherInfoWidget>
    with TickerProviderStateMixin {
  TextStyle style = TextStyle(
    fontSize: 20,
    fontStyle: FontStyle.italic,
  );
  AnimationController _cloudAnimationController;
  AnimationController _snowAnimationController;
  AnimationController _sunAnimationController;

  @override
  void initState() {
    super.initState();
    _cloudAnimationController = AnimationController(
        duration: Duration(seconds: 2),
        vsync: this,
        lowerBound: 0.8,
        upperBound: 1)
      ..repeat(reverse: true);

    _snowAnimationController =
        AnimationController(duration: Duration(seconds: 10), vsync: this)
          ..repeat();
    _sunAnimationController =
        AnimationController(duration: Duration(seconds: 2), vsync: this)
          ..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 75,
      child: Stack(children: [
        Align(
            alignment: Alignment.topCenter,
            child: Text("${widget.temperature}", style: style)),
        Align(
            alignment: Alignment.bottomCenter,
            child: _getAnimatedIcon(widget.temperature)),
      ]),
    );
  }

  Widget _getAnimatedIcon(double temperature) {
    if (temperature < 0) {
      return _getSnowyIcon();
    } else if (temperature < 10) {
      return _getCloudyIcon();
    } else {
      return _getSunnyIcon();
    }
  }

  Widget _getSnowyIcon() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size biggest = constraints.biggest;
        return Stack(
          children: [
            _getSnowflake(biggest, 0, 0),
            _getSnowflake(biggest, 0.42, 0),
            _getSnowflake(biggest, 0.7, 25),
            _getSnowflake(biggest, 0.28, 25),
            _getSnowflake(biggest, 0.14, 50),
            _getSnowflake(biggest, 0.56, 50),
          ],
        );
      },
    );
  }

  Widget _getCloudyIcon() {
    return Stack(children: [
      _getCloud(0.8, 0.8),
      _getCloud(0.5, 0.6)
    ]);
  }

  Widget _getCloud(double height, double width) {
    return Align(
      alignment: FractionalOffset(width, height),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _cloudAnimationController,
          curve: Curves.linear,
        ),
        child: Image(
            height: 40, width: 40, image: AssetImage('assets/clouds.png')),
      ),
    );
  }

  Widget _getSnowflake(Size containerSize, double start, double x) {
    const double size = 20;
    return Stack(children: [
      PositionedTransition(
        rect: RelativeRectTween(
          begin: RelativeRect.fromSize(
              Rect.fromLTWH(x, -size, size, size), containerSize),
          end: RelativeRect.fromSize(
              Rect.fromLTWH(x, containerSize.height, size, size),
              containerSize),
        ).animate(CurvedAnimation(
          parent: _snowAnimationController,
          curve: Interval(start, start + 0.3),
        )),
        child: RotationTransition(
          turns: CurvedAnimation(
            parent: _snowAnimationController,
            curve: Curves.linear,
          ),
          child: Image(
              height: size,
              width: size,
              image: AssetImage('assets/snow-icon.png')),
        ),
      ),
    ]);
  }

  Widget _getSunnyIcon() {
    Animation glowAnimation = Tween(begin: 5.0, end: 15.0)
        .animate(_sunAnimationController)
          ..addListener(() => setState(() {}));
    return Container(
      //color: background.evaluate(AlwaysStoppedAnimation(_cloudAnimationController.value)),
      child: RotationTransition(
          turns: CurvedAnimation(
            parent: _snowAnimationController,
            curve: Curves.linear,
          ),
          child: SvgPicture.asset(
            'assets/sun.svg',
            height: 40,
            width: 40,
          )),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(255, 27, 28, 30),
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(130, 237, 125, 58),
                blurRadius: glowAnimation.value,
                spreadRadius: glowAnimation.value)
          ]),
    );
  }

  @override
  void dispose() {
    _cloudAnimationController.dispose();
    _snowAnimationController.dispose();
    _sunAnimationController.dispose();
    super.dispose();
  }
}
