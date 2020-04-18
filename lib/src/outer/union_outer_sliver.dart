import 'package:flutter/widgets.dart';
import 'package:union_tabs/src/notification/union_scroll_notification.dart';

/// A delegate that supplies children for slivers using a builder callback.
/// [SliverChildListDelegate] override build, intend to send [UnionOverscrollNotification].
class UnionSliverChildListDelegate extends SliverChildListDelegate {
  UnionSliverChildListDelegate(
    List<Widget> children, {
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    int semanticIndexOffset = 0,
  }) : super(children,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            semanticIndexOffset: semanticIndexOffset);

  @override
  Widget build(BuildContext context, int index) {
    /// convert scrollNotification into UnionScrollNotification
    /// convert scrollNotification into UnionScrollNotification
    return UnionScrollChild(
      index: index,
      child: super.build(context, index),
    );
  }
}

/// A delegate that supplies children for slivers using a builder callback.
/// [SliverChildBuilderDelegate] override build, intend to send [UnionOverscrollNotification].
class UnionSliverChildBuilderDelegate extends SliverChildBuilderDelegate {
  UnionSliverChildBuilderDelegate(
    IndexedWidgetBuilder builder, {
    ChildIndexGetter findChildIndexCallback,
    int childCount,
    bool addAutomaticKeepAlives = true,
    bool addRepaintBoundaries = true,
    bool addSemanticIndexes = true,
    int semanticIndexOffset = 0,
  }) : super(builder,
            findChildIndexCallback: findChildIndexCallback,
            addAutomaticKeepAlives: addAutomaticKeepAlives,
            addRepaintBoundaries: addRepaintBoundaries,
            addSemanticIndexes: addSemanticIndexes,
            semanticIndexOffset: semanticIndexOffset);

  @override
  Widget build(BuildContext context, int index) {
    /// convert scrollNotification into UnionScrollNotification
    return UnionScrollChild(
      child: super.build(context, index),
      index: index,
    );
  }
}

class UnionScrollChild extends StatefulWidget {
  final Widget child;
  final int index;

  UnionScrollChild({Key key, @required this.child, @required this.index})
      : super(key: key);

  @override
  _UnionScrollChildState createState() => _UnionScrollChildState();
}

class _UnionScrollChildState extends State<UnionScrollChild> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          return handleScrollNotification(
              context: context,
              notification: notification,
              index: widget.index);
        },
        child: widget.child ?? Container());
  }

  /// 缓存startNotification, 当开始滑动的时候发送到上层[UnionTabBarView]；
  /// when overscroll begins, firstly send a startNotification.
  UnionScrollStartNotification _scrollStartNotification;

  /// 标记是否是边界滑动，如果是，处理ScrollEnd, 否则，不将滑动结束通知到上层[UnionTabBarView].
  /// if true, when scroll ends, send a endNotification.
  bool _overscroll = false;

  bool handleScrollNotification(
      {@required BuildContext context,
      @required ScrollNotification notification,
      @required int index}) {
    if (!defaultScrollNotificationPredicate(notification)) {
      return false;
    }

    if (notification is OverscrollNotification) {
      /// 发送startNotification
      /// dispatch a startNotification.
      if (_scrollStartNotification != null) {
        _scrollStartNotification.dispatch(context);
      }

      bool overscroll = true;
      if (!_overscroll) {
        setState(() {
          _overscroll = overscroll;
        });
      }

      _scrollStartNotification = null;

      UnionOverscrollNotification.merge(
              notification: notification, index: index)
          .dispatch(context);
    } else if (notification is ScrollEndNotification) {
      /// 发送endNotification
      /// dispatch a endNotification.
      if (_overscroll) {
        UnionScrollEndNotification.merge(
                notification: notification, index: index)
            .dispatch(context);
      }

      bool overscroll = false;
      if (_overscroll) {
        setState(() {
          _overscroll = overscroll;
        });
      }
      _scrollStartNotification = null;
    } else if (notification is ScrollStartNotification) {
      _scrollStartNotification = UnionScrollStartNotification.merge(
          notification: notification, index: index);
    } else if (notification is ScrollUpdateNotification) {
      if (_overscroll) {
        UnionScrollUpdateNotification.merge(
                notification: notification, index: index)
            .dispatch(context);
      }
    }

    return false;
  }
}
