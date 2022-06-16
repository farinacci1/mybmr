
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



/// {@template hero_dialog_route}
/// Custom [PageRoute] that creates an overlay dialog (popup effect).
///
/// Best used with a [Hero] animation.
/// {@endtemplate}
class HeroDialogRoute<T> extends PageRoute<T> {
  /// {@macro hero_dialog_route}
  HeroDialogRoute({
    @required WidgetBuilder builder,
     RouteSettings settings,
    bool fullscreenDialog = false,
    Color statusBarColor,
    Color bgColor = Colors.black54
  })  : _builder = builder,_statusBarColor=statusBarColor,_bgColor = bgColor,
        super(settings: settings, fullscreenDialog: fullscreenDialog);

  final WidgetBuilder _builder;
  final Color _statusBarColor;
  final Color _bgColor;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => _bgColor;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    if(_statusBarColor != null){
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor:_statusBarColor
      ));
    }

    return _builder(context);
  }

  @override
  String get barrierLabel => 'Popup dialog open';
}