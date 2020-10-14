import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:union_tabs/src/notification/scroll_position.dart';

class UnionOuterScrollPosition extends PagePosition implements PageMetrics {
  UnionOuterScrollPosition({
    ScrollPhysics physics,
    ScrollContext context,
    int initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
    ScrollPosition oldPosition,
  }) : super(
          physics: physics,
          context: context,
          initialPage: initialPage,
          keepPage: keepPage,
          viewportFraction: viewportFraction,
          oldPosition: oldPosition,
        );

  double _overscrollOffset = -1;
  bool _overscroll = false;

  bool get overscroll => _overscroll;

  @mustCallSuper
  void onGestureDone() {
    _overscrollOffset = -1;
    _overscroll = false;
  }

  @override
  double setPixels(double newPixels) {
    if (!_overscroll) {
      return super.setPixels(newPixels);
    } else {
      double overscroll = newPixels + _overscrollOffset;
      if (overscroll != 0.0) {
        _overscroll = true;
        _overscrollOffset = overscroll;
        didOverscrollBy(overscroll);
        return overscroll;
      }
    }
    return super.setPixels(newPixels);
  }

  @override
  void dispose() {
    _overscroll = false;
    _overscrollOffset = -1;
    super.dispose();
  }
}
