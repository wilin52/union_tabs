import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:union_tabs/src/notification/union_scroll_notification.dart';

import 'union_outer_page_view.dart';

class UnionOuterGestureDelegate {
  UnionOuterPageController pageController;
  TabController tabController;

  UnionOuterGestureDelegate(
      {@required this.pageController, @required this.tabController});

  /// 用于手势下发。
  /// record the gesture.
  Drag _drag;

  /// 将处理UnionScrollNotification.
  bool handleUnionScrollNotification(
      BuildContext context, UnionScrollNotification notification) {
    if (tabController.index != notification.index) {
      return false;
    }

    if (notification is UnionScrollStartNotification) {
      _drag = pageController.position.drag(notification.dragDetails, () {
        _drag = null;
      });
    } else if (notification is UnionOverscrollNotification) {
      if (_drag == null) {
        return true;
      }

      /// 计算用户滑动
      /// update the offset, to update the indicator's position
      MediaQueryData data = MediaQuery.of(context);
      tabController.offset =
          (tabController.offset + notification.overscroll / data.size.width)
              .clamp(-1.0, 1.0);

      if (notification.dragDetails != null) {
        /// update the viewpager's position
        _drag.update(notification.dragDetails);
      }
    } else if (notification is UnionScrollEndNotification) {
      _drag?.cancel();
      _drag = null;
      double dx = notification.dragDetails?.velocity?.pixelsPerSecond?.dx ?? 0;
      if (dx != 0) {
        int offset = dx > 0 ? -1 : 1;
        int index = tabController.index + offset;
        if (index < 0) index = 0;
        if (index >= tabController.length) index = tabController.length - 1;

        tabController.animateTo(index, duration: Duration(milliseconds: 500));
      }
    } else if (notification is UnionScrollUpdateNotification) {
      if (_drag != null && notification.dragDetails != null) {
        /// update the viewpager's position
        _drag.update(notification.dragDetails);

        /// 计算用户滑动
        /// update the offset, to update the indicator's position
        MediaQueryData data = MediaQuery.of(context);
        tabController.offset = (tabController.offset +
                notification.dragDetails.delta.dx / data.size.width)
            .clamp(-1.0, 1.0);
      }
    }
    return true;
  }

  void dispose() {
    pageController = null;
    tabController = null;
    _drag?.cancel();
    _drag = null;
  }
}
