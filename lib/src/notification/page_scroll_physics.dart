import 'package:flutter/widgets.dart';

import 'scroll_position.dart';

class UnionPageScrollPhysics extends ScrollPhysics {
  /// Creates physics for a [UnionInnerPageView].
  const UnionPageScrollPhysics({ScrollPhysics parent})
      : super(parent: parent);

  @override
  UnionPageScrollPhysics applyTo(ScrollPhysics ancestor) {
    return UnionPageScrollPhysics(parent: buildParent(ancestor));
  }

  double _getPage(ScrollPosition position) {
    if (position is PagePosition) return position.page;
    return position.pixels / position.viewportDimension;
  }

  double _getPixels(ScrollPosition position, double page) {
    if (position is PagePosition) return position.getPixelsFromPage(page);
    return page * position.viewportDimension;
  }

  double _getTargetPixels(
      ScrollPosition position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity)
      page -= 0.5;
    else if (velocity > tolerance.velocity) page += 0.5;
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent))
      return super.createBallisticSimulation(position, velocity);
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels)
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
