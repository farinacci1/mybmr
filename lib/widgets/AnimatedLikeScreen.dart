///
///  create by zmtzawqlp on 2019/5/27
///
import 'package:flutter/material.dart';
import 'package:like_button/src/painter/bubbles_painter.dart';
import 'package:like_button/src/painter/circle_painter.dart';
import 'package:like_button/src/utils/like_button_model.dart';
import 'package:like_button/src/utils/like_button_typedef.dart';
class AnimatedLikeScreen extends StatefulWidget {
  const AnimatedLikeScreen(
      {Key key,
      this.size = 30.0,
      double bubblesSize,
      double circleSize,
      this.isLiked = false,
      this.mainAxisAlignment = MainAxisAlignment.center,
      this.crossAxisAlignment = CrossAxisAlignment.center,
      this.animationDuration = const Duration(milliseconds: 600),
      this.bubblesColor = const BubblesColor(
        dotPrimaryColor: Color(0xFFFFC107),
        dotSecondaryColor: Color(0xFFFF9800),
        dotThirdColor: Color(0xFFFF5722),
        dotLastColor: Color(0xFFF44336),
      ),
        this.hasScaleFactor = true,
      this.circleColor =
          const CircleColor(start: Color(0xFFFF5722), end: Color(0xFFFFC107)),
      this.onTap,
      this.padding,
      this.isAnimating,
      this.onEnd,
        this.shouldDisappear = false,
      this.icon,
      this.iconColor})
      : bubblesSize = bubblesSize ?? size * 2.0,
        circleSize = circleSize ?? size * 0.8,
        super(key: key);

  ///size of like widget
  final double size;
  /// bool hasScaleFactor
  final bool hasScaleFactor;
  ///icon Color
  final Color iconColor;
  final shouldDisappear;
  ///animation duration to change isLiked state
  final Duration animationDuration;

  ///total size of bubbles
  final double bubblesSize;

  ///colors of bubbles
  final BubblesColor bubblesColor;

  ///size of circle
  final double circleSize;

  ///colors of circle
  final CircleColor circleColor;

  /// tap call back of like button
  final LikeButtonTapCallback onTap;

  ///whether it is liked
  final bool isLiked;

  ///icon data
  final IconData icon;

  ///isAnimating
  final bool isAnimating;

  /// mainAxisAlignment for like button
  final MainAxisAlignment mainAxisAlignment;

  // crossAxisAlignment for like button
  final CrossAxisAlignment crossAxisAlignment;


  final VoidCallback onEnd;

  /// padding of like button
  final EdgeInsetsGeometry padding;

  @override
  State<StatefulWidget> createState() => AnimatedLikeScreenState();
}

class AnimatedLikeScreenState extends State<AnimatedLikeScreen>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _outerCircleAnimation;
  Animation<double> _innerCircleAnimation;
  Animation<double> _scaleAnimation;
  Animation<double> _bubblesAnimation;
  Animation<double> _bounceAnimation;

  bool _isLiked = false;
  bool primaryAnimationComplete = false;
  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;

    _controller =
        AnimationController(duration: widget.animationDuration, vsync: this);

    _initAnimations();
  }

  @override
  void didUpdateWidget(AnimatedLikeScreen oldWidget) {
    if (widget.isAnimating) {
      _isLiked = widget.isLiked;
      _handleIsLikeChanged(_isLiked);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[
      AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext c, Widget w) {

          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                top: (widget.size - widget.bubblesSize) / 2.0,
                left: (widget.size - widget.bubblesSize) / 2.0,
                child: CustomPaint(
                  size: Size(widget.bubblesSize, widget.bubblesSize),
                  painter: BubblesPainter(
                    currentProgress: _bubblesAnimation.value,
                    color1: widget.bubblesColor.dotPrimaryColor,
                    color2: widget.bubblesColor.dotSecondaryColor,
                    color3: widget.bubblesColor.dotThirdColorReal,
                    color4: widget.bubblesColor.dotLastColorReal,
                  ),
                ),
              ),
              Positioned(
                top: (widget.size - widget.circleSize) / 2.0,
                left: (widget.size - widget.circleSize) / 2.0,
                child: CustomPaint(
                  size: Size(widget.circleSize, widget.circleSize),
                  painter: CirclePainter(
                    innerCircleRadiusProgress: _innerCircleAnimation.value,
                    outerCircleRadiusProgress: _outerCircleAnimation.value,
                    circleColor: widget.circleColor,
                  ),
                ),
              ),
              Container(
                width: widget.size,
                height: widget.size,
                alignment: Alignment.center,
                child: Container(

                    height: widget.size,
                    width: widget.size,
                    child: Icon(
                      widget.icon,
                      size:   widget.hasScaleFactor ? ((widget.size * .83) * _scaleAnimation.value) *_bounceAnimation.value
                      :  ((widget.size * .83) ) *_bounceAnimation.value,
                      color: widget.iconColor,
                    ),

                  ),

              ),
            ],
          );
        },
      ),
    ];

    Widget result = Column(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: children,
    );

    if (widget.padding != null) {
      result = Padding(
        padding: widget.padding,
        child: result,
      );
    }
    return result;
  }

  Future<void> _handleIsLikeChanged(bool isLiked) async {
    await _controller.reset();
    await _controller.forward();
    Future.delayed(Duration(milliseconds: 50));
    if (widget.onEnd != null) widget.onEnd();
  }

  void _initAnimations() {
    _initControlAnimation();
  }

  void _initControlAnimation() {
    _outerCircleAnimation = Tween<double>(
      begin: 0.1,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.3,
          curve: Curves.ease,
        ),
      ),
    );
    _innerCircleAnimation = Tween<double>(
      begin: 0.2,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.2,
          0.5,
          curve: Curves.ease,
        ),
      ),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.2,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.1,
          0.8,
          curve: Curves.ease,
        ),
      ),
    );

    _bubblesAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.1,
          1.0,
          curve: Curves.decelerate,
        ),
      ),
    );
    _bounceAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.85,
          1,
          curve: Curves.ease,
        ),
      ),
    );

  }
}
