import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// A [Notification] related to scrolling.
///
/// [Scrollable] widgets notify their ancestors about scrolling-related changes.
/// The notifications have the following lifecycle:
///
///  * A [UnionScrollStartNotification], which indicates that the widget has started
///    scrolling.
///  * Zero or more [UnionScrollUpdateNotification]s, which indicate that the widget
///    has changed its scroll position, mixed with zero or more
///    [OverscrollNotification]s, which indicate that the widget has not changed
///    its scroll position because the change would have caused its scroll
///    position to go outside its scroll bounds.
///  * Interspersed with the [UnionScrollUpdateNotification]s and
///    [OverscrollNotification]s are zero or more [UserScrollNotification]s,
///    which indicate that the user has changed the direction in which they are
///    scrolling.
///  * A [UnionScrollEndNotification], which indicates that the widget has stopped
///    scrolling.
///  * A [UnionUserScrollNotification], with a [UnionUserScrollNotification.direction] of
///    [ScrollDirection.idle].
///
/// Notifications bubble up through the tree, which means a given
/// [NotificationListener] will receive notifications for all descendant
/// [Scrollable] widgets. To focus on notifications from the nearest
/// [Scrollable] descendant, check that the [depth] property of the notification
/// is zero.
///
/// When a scroll notification is received by a [NotificationListener], the
/// listener will have already completed build and layout, and it is therefore
/// too late for that widget to call [State.setState]. Any attempt to adjust the
/// build or layout based on a scroll notification would result in a layout that
/// lagged one frame behind, which is a poor user experience. Scroll
/// notifications are therefore primarily useful for paint effects (since paint
/// happens after layout). The [GlowingOverscrollIndicator] and [Scrollbar]
/// widgets are examples of paint effects that use scroll notifications.
///
/// To drive layout based on the scroll position, consider listening to the
/// [ScrollPosition] directly (or indirectly via a [ScrollController]).
abstract class UnionScrollNotification extends LayoutChangedNotification
    with ViewportNotificationMixin {
  /// Initializes fields for subclasses.
  UnionScrollNotification({
    @required this.metrics,
    @required this.context,
    @required this.index,
  });

  /// A description of a [Scrollable]'s contents, useful for modeling the state
  /// of its viewport.
  final ScrollMetrics metrics;

  /// The build context of the widget that fired this notification.
  ///
  /// This can be used to find the scrollable's render objects to determine the
  /// size of the viewport, for instance.
  final BuildContext context;

  /// index of [UnionPageView] children
  int index = -1;

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('$metrics');
  }
}

/// A notification that a [Scrollable] widget has started scrolling.
///
/// See also:
///
///  * [UnionScrollEndNotification], which indicates that scrolling has stopped.
///  * [UnionScrollNotification], which describes the notification lifecycle.
class UnionScrollStartNotification extends UnionScrollNotification {
  /// Creates a notification that a [Scrollable] widget has started scrolling.
  UnionScrollStartNotification({
    @required ScrollMetrics metrics,
    @required BuildContext context,
    @required int index,
    this.dragDetails,
  }) : super(metrics: metrics, context: context, index: index);

  /// If the [Scrollable] started scrolling because of a drag, the details about
  /// that drag start.
  ///
  /// Otherwise, null.
  final DragStartDetails dragDetails;

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    if (dragDetails != null) description.add('$dragDetails');
  }

  static UnionScrollStartNotification merge(
      {BuildContext context,
      @required ScrollStartNotification notification,
      @required int index}) {
    return UnionScrollStartNotification(
        metrics: notification.metrics,
        context: context ?? notification.context,
        index: index,
        dragDetails: notification.dragDetails);
  }
}

/// A notification that a [Scrollable] widget has changed its scroll position.
///
/// See also:
///
///  * [UnionOverscrollNotification], which indicates that a [Scrollable] widget
///    has not changed its scroll position because the change would have caused
///    its scroll position to go outside its scroll bounds.
///  * [UnionScrollNotification], which describes the notification lifecycle.
class UnionScrollUpdateNotification extends UnionScrollNotification {
  /// Creates a notification that a [Scrollable] widget has changed its scroll
  /// position.
  UnionScrollUpdateNotification({
    @required ScrollMetrics metrics,
    @required BuildContext context,
    @required int index,
    this.dragDetails,
    this.scrollDelta,
  }) : super(metrics: metrics, context: context, index: index);

  /// If the [Scrollable] changed its scroll position because of a drag, the
  /// details about that drag update.
  ///
  /// Otherwise, null.
  final DragUpdateDetails dragDetails;

  /// The distance by which the [Scrollable] was scrolled, in logical pixels.
  final double scrollDelta;

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('scrollDelta: $scrollDelta');
    if (dragDetails != null) description.add('$dragDetails');
  }

  static UnionScrollUpdateNotification merge(
      {BuildContext context,
      @required ScrollUpdateNotification notification,
      @required int index}) {
    return UnionScrollUpdateNotification(
        metrics: notification.metrics,
        context: context ?? notification.context,
        index: index,
        dragDetails: notification.dragDetails,
        scrollDelta: notification.scrollDelta);
  }
}

/// A notification that a [Scrollable] widget has not changed its scroll position
/// because the change would have caused its scroll position to go outside of
/// its scroll bounds.
///
/// See also:
///
///  * [UnionScrollUpdateNotification], which indicates that a [Scrollable] widget
///    has changed its scroll position.
///  * [UnionScrollNotification], which describes the notification lifecycle.
class UnionOverscrollNotification extends UnionScrollNotification {
  /// Creates a notification that a [Scrollable] widget has changed its scroll
  /// position outside of its scroll bounds.
  UnionOverscrollNotification({
    @required ScrollMetrics metrics,
    @required BuildContext context,
    @required int index,
    this.dragDetails,
    @required this.overscroll,
    this.velocity = 0.0,
  })  : assert(overscroll != null),
        assert(overscroll.isFinite),
        assert(overscroll != 0.0),
        assert(velocity != null),
        super(metrics: metrics, context: context, index: index);

  /// If the [Scrollable] overscrolled because of a drag, the details about that
  /// drag update.
  ///
  /// Otherwise, null.
  final DragUpdateDetails dragDetails;

  /// The number of logical pixels that the [Scrollable] avoided scrolling.
  ///
  /// This will be negative for overscroll on the "start" side and positive for
  /// overscroll on the "end" side.
  final double overscroll;

  /// The velocity at which the [ScrollPosition] was changing when this
  /// overscroll happened.
  ///
  /// This will typically be 0.0 for touch-driven overscrolls, and positive
  /// for overscrolls that happened from a [BallisticScrollActivity] or
  /// [DrivenScrollActivity].
  final double velocity;

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('overscroll: ${overscroll.toStringAsFixed(1)}');
    description.add('velocity: ${velocity.toStringAsFixed(1)}');
    if (dragDetails != null) description.add('$dragDetails');
  }

  static UnionOverscrollNotification merge(
      {BuildContext context,
      @required OverscrollNotification notification,
      @required int index}) {
    return UnionOverscrollNotification(
      metrics: notification.metrics,
      context: context ?? notification.context,
      index: index,
      dragDetails: notification.dragDetails,
      overscroll: notification.overscroll,
      velocity: notification.velocity,
    );
  }
}

/// A notification that a [Scrollable] widget has stopped scrolling.
///
/// See also:
///
///  * [UnionScrollStartNotification], which indicates that scrolling has started.
///  * [UnionScrollNotification], which describes the notification lifecycle.
class UnionScrollEndNotification extends UnionScrollNotification {
  /// Creates a notification that a [Scrollable] widget has stopped scrolling.
  UnionScrollEndNotification({
    @required ScrollMetrics metrics,
    @required BuildContext context,
    @required int index,
    this.dragDetails,
  }) : super(metrics: metrics, context: context, index: index);

  /// If the [Scrollable] stopped scrolling because of a drag, the details about
  /// that drag end.
  ///
  /// Otherwise, null.
  ///
  /// If a drag ends with some residual velocity, a typical [ScrollPhysics] will
  /// start a ballistic scroll, which delays the [UnionScrollEndNotification] until
  /// the ballistic simulation completes, at which time [dragDetails] will
  /// be null. If the residual velocity is too small to trigger ballistic
  /// scrolling, then the [UnionScrollEndNotification] will be dispatched immediately
  /// and [dragDetails] will be non-null.
  final DragEndDetails dragDetails;

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    if (dragDetails != null) description.add('$dragDetails');
  }

  static UnionScrollEndNotification merge({
    BuildContext context,
    @required ScrollEndNotification notification,
    @required int index,
  }) {
    return UnionScrollEndNotification(
      metrics: notification.metrics,
      context: context ?? notification.context,
      index: index,
      dragDetails: notification.dragDetails,
    );
  }
}

/// A notification that the user has changed the direction in which they are
/// scrolling.
///
/// See also:
///
///  * [UnionScrollNotification], which describes the notification lifecycle.
class UnionUserScrollNotification extends UnionScrollNotification {
  /// Creates a notification that the user has changed the direction in which
  /// they are scrolling.
  UnionUserScrollNotification({
    @required ScrollMetrics metrics,
    @required BuildContext context,
    @required int index,
    this.direction,
  }) : super(metrics: metrics, context: context, index: index);

  /// The direction in which the user is scrolling.
  final ScrollDirection direction;

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('direction: $direction');
  }

  static UnionUserScrollNotification merge({
    BuildContext context,
    @required UserScrollNotification notification,
    @required int index,
  }) {
    return UnionUserScrollNotification(
      metrics: notification.metrics,
      context: context ?? notification.context,
      index: index,
      direction: notification.direction,
    );
  }
}

/// A predicate for [UnionScrollNotification], used to customize widgets that
/// listen to notifications from their children.
typedef NestScrollNotificationPredicate = bool Function(
    UnionScrollNotification notification);

/// A [NestScrollNotificationPredicate] that checks whether
/// `notification.depth == 0`, which means that the notification did not bubble
/// through any intervening scrolling widgets.
bool defaultUnionScrollNotificationPredicate(
    UnionScrollNotification notification) {
  return notification.depth == 0;
}
