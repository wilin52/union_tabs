import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:union_tabs/src/notification/page_controller.dart';
import 'package:union_tabs/src/notification/page_scroll_physics.dart';

import 'union_inner_scrollable.dart';
import 'union_tabs_provider.dart';

// Having this global (mutable) page controller is a bit of a hack. We need it
// to plumb in the factory for _UnionPagePosition, but it will end up accumulating
// a large list of scroll positions. As long as you don't try to actually
// control the scroll positions, everything should be fine.
final UnionPageController _defaultPageController =
    UnionPageController();
const UnionPageScrollPhysics _kPagePhysics = UnionPageScrollPhysics();

/// A scrollable list that works page by page.
///
/// Each child of a page view is forced to be the same size as the viewport.
///
/// You can use a [UnionPageController] to control which page is visible in the view.
/// In addition to being able to control the pixel offset of the content inside
/// the [UnionInnerPageView], a [UnionPageController] also lets you control the offset in terms
/// of pages, which are increments of the viewport size.
///
/// The [UnionPageController] can also be used to control the
/// [UnionPageController.initialPage], which determines which page is shown when the
/// [UnionInnerPageView] is first constructed, and the [PageController.viewportFraction],
/// which determines the size of the pages as a fraction of the viewport size.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=J1gE9xvph-A}
///
/// See also:
///
///  * [UnionPageController], which controls which page is visible in the view.
///  * [SingleChildScrollView], when you need to make a single child scrollable.
///  * [ListView], for a scrollable list of boxes.
///  * [GridView], for a scrollable grid of boxes.
///  * [ScrollNotification] and [NotificationListener], which can be used to watch
///    the scroll position without using a [ScrollController].
class UnionInnerPageView extends StatefulWidget {
  /// Creates a scrollable list that works page by page from an explicit [List]
  /// of widgets.
  ///
  /// This constructor is appropriate for page views with a small number of
  /// children because constructing the [List] requires doing work for every
  /// child that could possibly be displayed in the page view, instead of just
  /// those children that are actually visible.
  UnionInnerPageView({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    UnionPageController controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    List<Widget> children = const <Widget>[],
    this.dragStartBehavior = DragStartBehavior.start,
  })  : controller = controller ?? _defaultPageController,
        childrenDelegate = SliverChildListDelegate(children),
        super(key: key);

  /// Creates a scrollable list that works page by page using widgets that are
  /// created on demand.
  ///
  /// This constructor is appropriate for page views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// Providing a non-null [itemCount] lets the [UnionInnerPageView] compute the maximum
  /// scroll extent.
  ///
  /// [itemBuilder] will be called only with indices greater than or equal to
  /// zero and less than [itemCount].
  ///
  /// [UnionInnerPageView.builder] by default does not support child reordering. If
  /// you are planning to change child order at a later time, consider using
  /// [UnionInnerPageView] or [UnionInnerPageView.custom].
  UnionInnerPageView.builder({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    UnionPageController controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    @required IndexedWidgetBuilder itemBuilder,
    int itemCount,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : controller = controller ?? _defaultPageController,
        childrenDelegate =
            SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
        super(key: key);

  /// Creates a scrollable list that works page by page with a custom child
  /// model.
  ///
  /// {@tool sample}
  ///
  /// This [UnionInnerPageView] uses a custom [SliverChildBuilderDelegate] to support child
  /// reordering.
  ///
  /// ```dart
  /// class MyPageView extends StatefulWidget {
  ///   @override
  ///   _MyPageViewState createState() => _MyPageViewState();
  /// }
  ///
  /// class _MyPageViewState extends State<MyPageView> {
  ///   List<String> items = <String>['1', '2', '3', '4', '5'];
  ///
  ///   void _reverse() {
  ///     setState(() {
  ///       items = items.reversed.toList();
  ///     });
  ///   }
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return Scaffold(
  ///       body: SafeArea(
  ///         child: UnionPageView.custom(
  ///           childrenDelegate: SliverChildBuilderDelegate(
  ///             (BuildContext context, int index) {
  ///               return KeepAlive(
  ///                 data: items[index],
  ///                 key: ValueKey<String>(items[index]),
  ///               );
  ///             },
  ///             childCount: items.length,
  ///             findChildIndexCallback: (Key key) {
  ///               final ValueKey valueKey = key;
  ///               final String data = valueKey.value;
  ///               return items.indexOf(data);
  ///             }
  ///           ),
  ///         ),
  ///       ),
  ///       bottomNavigationBar: BottomAppBar(
  ///         child: Row(
  ///           mainAxisAlignment: MainAxisAlignment.center,
  ///           children: <Widget>[
  ///             FlatButton(
  ///               onPressed: () => _reverse(),
  ///               child: Text('Reverse items'),
  ///             ),
  ///           ],
  ///         ),
  ///       ),
  ///     );
  ///   }
  /// }
  ///
  /// class KeepAlive extends StatefulWidget {
  ///   const KeepAlive({Key key, this.data}) : super(key: key);
  ///
  ///   final String data;
  ///
  ///   @override
  ///   _KeepAliveState createState() => _KeepAliveState();
  /// }
  ///
  /// class _KeepAliveState extends State<KeepAlive> with AutomaticKeepAliveClientMixin{
  ///   @override
  ///   bool get wantKeepAlive => true;
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     super.build(context);
  ///     return Text(widget.data);
  ///   }
  /// }
  /// ```
  /// {@end-tool}
  UnionInnerPageView.custom({
    Key key,
    this.scrollDirection = Axis.horizontal,
    this.reverse = false,
    UnionPageController controller,
    this.physics,
    this.pageSnapping = true,
    this.onPageChanged,
    @required this.childrenDelegate,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(childrenDelegate != null),
        controller = controller ?? _defaultPageController,
        super(key: key);

  /// The axis along which the page view scrolls.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// Whether the page view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the page view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the page view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// An object that can be used to control the position to which this page
  /// view is scrolled.
  final UnionPageController controller;

  /// How the page view should respond to user input.
  ///
  /// For example, determines how the page view continues to animate after the
  /// user stops dragging the page view.
  ///
  /// The physics are modified to snap to page boundaries using
  /// [UnionInnerPageScrollPhysics] prior to being used.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics physics;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  final bool pageSnapping;

  /// Called whenever the page in the center of the viewport changes.
  final ValueChanged<int> onPageChanged;

  /// A delegate that provides the children for the [UnionInnerPageView].
  ///
  /// The [UnionInnerPageView.custom] constructor lets you specify this delegate
  /// explicitly. The [UnionInnerPageView] and [UnionInnerPageView.builder] constructors create a
  /// [childrenDelegate] that wraps the given [List] and [IndexedWidgetBuilder],
  /// respectively.
  final SliverChildDelegate childrenDelegate;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  @override
  _UnionInnerPageViewState createState() => _UnionInnerPageViewState();
}

class _UnionInnerPageViewState extends State<UnionInnerPageView> {
  int _lastReportedPage = 0;

  @override
  void initState() {
    super.initState();
    _lastReportedPage = widget.controller.initialPage;
  }

  AxisDirection _getDirection(BuildContext context) {
    switch (widget.scrollDirection) {
      case Axis.horizontal:
        assert(debugCheckHasDirectionality(context));
        final TextDirection textDirection = Directionality.of(context);
        final AxisDirection axisDirection =
            textDirectionToAxisDirection(textDirection);
        return widget.reverse
            ? flipAxisDirection(axisDirection)
            : axisDirection;
      case Axis.vertical:
        return widget.reverse ? AxisDirection.up : AxisDirection.down;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final AxisDirection axisDirection = _getDirection(context);
    final ScrollPhysics physics = widget.pageSnapping
        ? _kPagePhysics.applyTo(widget.physics)
        : widget.physics;

    return TabBarOverScrollStateProvider(
      builder: (context) {
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification.depth == 0 &&
                widget.onPageChanged != null &&
                notification is ScrollUpdateNotification) {
              final PageMetrics metrics = notification.metrics;
              final int currentPage = metrics.page.round();
              if (currentPage != _lastReportedPage) {
                _lastReportedPage = currentPage;
                widget.onPageChanged(currentPage);
              }
            } else if (notification is OverscrollNotification) {
              TabBarOverScrollStateProvider.of(notification.context)
                  ?.setOverScroll(true);
            } else if (notification is ScrollEndNotification) {
              TabBarOverScrollStateProvider.of(notification.context)
                  ?.setOverScroll(false);
            }
            return false;
          },
          child: UnionInnerScrollable(
            dragStartBehavior: widget.dragStartBehavior,
            axisDirection: axisDirection,
            controller: widget.controller,
            physics: physics,
            viewportBuilder: (BuildContext context, ViewportOffset position) {
              return Viewport(
                cacheExtent: 0.0,
                axisDirection: axisDirection,
                offset: position,
                slivers: <Widget>[
                  SliverFillViewport(
                    viewportFraction: widget.controller.viewportFraction,
                    delegate: widget.childrenDelegate,
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description
        .add(EnumProperty<Axis>('scrollDirection', widget.scrollDirection));
    description.add(
        FlagProperty('reverse', value: widget.reverse, ifTrue: 'reversed'));
    description.add(DiagnosticsProperty<UnionPageController>(
        'controller', widget.controller,
        showName: false));
    description.add(DiagnosticsProperty<ScrollPhysics>(
        'physics', widget.physics,
        showName: false));
    description.add(FlagProperty('pageSnapping',
        value: widget.pageSnapping, ifFalse: 'snapping disabled'));
  }
}
