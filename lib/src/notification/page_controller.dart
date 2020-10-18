import 'package:flutter/widgets.dart';

import 'scroll_position.dart';

class UnionPageController extends ScrollController {
  /// Creates a page controller.
  ///
  /// The [initialPage], [keepPage], and [viewportFraction] arguments must not be null.
  UnionPageController({
    this.initialPage = 0,
    this.keepPage = true,
    this.viewportFraction = 1.0,
  })  : assert(initialPage != null),
        assert(keepPage != null),
        assert(viewportFraction != null),
        assert(viewportFraction > 0.0);

  /// The page to show when first creating the [UnionInnerPageView].
  final int initialPage;

  /// Save the current [page] with [PageStorage] and restore it if
  /// this controller's scrollable is recreated.
  ///
  /// If this property is set to false, the current [page] is never saved
  /// and [initialPage] is always used to initialize the scroll offset.
  /// If true (the default), the initial page is used the first time the
  /// controller's scrollable is created, since there's isn't a page to
  /// restore yet. Subsequently the saved page is restored and
  /// [initialPage] is ignored.
  ///
  /// See also:
  ///
  ///  * [PageStorageKey], which should be used when more than one
  ///    scrollable appears in the same route, to distinguish the [PageStorage]
  ///    locations used to save scroll offsets.
  final bool keepPage;

  /// The fraction of the viewport that each page should occupy.
  ///
  /// Defaults to 1.0, which means each page fills the viewport in the scrolling
  /// direction.
  final double viewportFraction;

  /// The current page displayed in the controlled [UnionInnerPageView].
  ///
  /// There are circumstances that this [UnionPageController] can't know the current
  /// page. Reading [page] will throw an [AssertionError] in the following cases:
  ///
  /// 1. No [UnionInnerPageView] is currently using this [UnionPageController]. Once a
  /// [UnionInnerPageView] starts using this [UnionPageController], the new [page]
  /// position will be derived:
  ///
  ///   * First, based on the attached [UnionInnerPageView]'s [BuildContext] and the
  ///     position saved at that context's [PageStorage] if [keepPage] is true.
  ///   * Second, from the [UnionPageController]'s [initialPage].
  ///
  /// 2. More than one [UnionInnerPageView] using the same [UnionPageController].
  ///
  /// The [hasClients] property can be used to check if a [UnionInnerPageView] is attached
  /// prior to accessing [page].
  double get page {
    assert(
      positions.isNotEmpty,
      'UnionPageController.page cannot be accessed before a UnionPageView is built with it.',
    );
    assert(
      positions.length == 1,
      'The page property cannot be read when multiple PageViews are attached to '
      'the same UnionPageController.',
    );
    final PagePosition position = this.position as PagePosition;
    return position.page;
  }

  /// Animates the controlled [UnionInnerPageView] from the current page to the given page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> animateToPage(
    int page, {
    @required Duration duration,
    @required Curve curve,
  }) {
    final PagePosition position = this.position as PagePosition;
    return position.animateTo(
      position.getPixelsFromPage(page.toDouble()),
      duration: duration,
      curve: curve,
    );
  }

  /// Changes which page is displayed in the controlled [UnionInnerPageView].
  ///
  /// Jumps the page position from its current value to the given value,
  /// without animation, and without checking if the new value is in range.
  void jumpToPage(int page) {
    final PagePosition position = this.position as PagePosition;
    position.jumpTo(position.getPixelsFromPage(page.toDouble()));
  }

  /// Animates the controlled [UnionInnerPageView] to the next page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> nextPage({@required Duration duration, @required Curve curve}) {
    return animateToPage(page.round() + 1, duration: duration, curve: curve);
  }

  /// Animates the controlled [UnionInnerPageView] to the previous page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  ///
  /// The `duration` and `curve` arguments must not be null.
  Future<void> previousPage(
      {@required Duration duration, @required Curve curve}) {
    return animateToPage(page.round() - 1, duration: duration, curve: curve);
  }

  @override
  ScrollPosition createScrollPosition(ScrollPhysics physics,
      ScrollContext context, ScrollPosition oldPosition) {
    return PagePosition(
      physics: physics,
      context: context,
      initialPage: initialPage,
      keepPage: keepPage,
      viewportFraction: viewportFraction,
      oldPosition: oldPosition,
    );
  }

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    final PagePosition pagePosition = position as PagePosition;
    pagePosition.viewportFraction = viewportFraction;
  }
}
