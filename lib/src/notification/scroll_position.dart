// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/foundation.dart' show precisionErrorTolerance;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class PagePosition extends ScrollPositionWithSingleContext implements PageMetrics {
  PagePosition({
    ScrollPhysics physics,
    ScrollContext context,
    this.initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
    ScrollPosition oldPosition,
  }) : assert(initialPage != null),
        assert(keepPage != null),
        assert(viewportFraction != null),
        assert(viewportFraction > 0.0),
        _viewportFraction = viewportFraction,
        _pageToUseOnStartup = initialPage.toDouble(),
        super(
        physics: physics,
        context: context,
        initialPixels: null,
        keepScrollOffset: keepPage,
        oldPosition: oldPosition,
      );

  final int initialPage;
  double _pageToUseOnStartup;

  /// If [pixels] isn't set by [applyViewportDimension] before [dispose] is
  /// called, this could throw an assert as [pixels] will be set to null.
  ///
  /// With [Tab]s, this happens when there are nested [TabBarView]s and there
  /// is an attempt to warp over the nested tab to a tab adjacent to it.
  ///
  /// This flag will be set to true once the dimensions have been established
  /// and [pixels] is set.
  bool isInitialPixelsValueSet = false;

  @override
  void dispose() {
    // TODO(shihaohong): remove workaround once these issues have been
    // resolved, https://github.com/flutter/flutter/issues/32054,
    // https://github.com/flutter/flutter/issues/32056
    // Sets `pixels` to a non-null value before `ScrollPosition.dispose` is
    // invoked if it was never set by `applyViewportDimension`.
    if (pixels == null && !isInitialPixelsValueSet) {
      correctPixels(0);
    }
    super.dispose();
  }

  @override
  double get viewportFraction => _viewportFraction;
  double _viewportFraction;
  set viewportFraction(double value) {
    if (_viewportFraction == value)
      return;
    final double oldPage = page;
    _viewportFraction = value;
    if (oldPage != null)
      forcePixels(getPixelsFromPage(oldPage));
  }

  double getPageFromPixels(double pixels, double viewportDimension) {
    final double actual = math.max(0.0, pixels) / math.max(1.0, viewportDimension * viewportFraction);
    final double round = actual.roundToDouble();
    if ((actual - round).abs() < precisionErrorTolerance) {
      return round;
    }
    return actual;
  }

  double getPixelsFromPage(double page) {
    return page * viewportDimension * viewportFraction;
  }

  @override
  double get page {
    assert(
    pixels == null || (minScrollExtent != null && maxScrollExtent != null),
    'Page value is only available after content dimensions are established.',
    );
    return pixels == null ? null : getPageFromPixels(pixels.clamp(minScrollExtent, maxScrollExtent), viewportDimension);
  }

  @override
  void saveScrollOffset() {
    PageStorage.of(context.storageContext)?.writeState(context.storageContext, getPageFromPixels(pixels, viewportDimension));
  }

  @override
  void restoreScrollOffset() {
    if (pixels == null) {
      final double value = PageStorage.of(context.storageContext)?.readState(context.storageContext);
      if (value != null)
        _pageToUseOnStartup = value;
    }
  }

  @override
  bool applyViewportDimension(double viewportDimension) {
    final double oldViewportDimensions = this.viewportDimension;
    final bool result = super.applyViewportDimension(viewportDimension);
    final double oldPixels = pixels;
    final double page = (oldPixels == null || oldViewportDimensions == 0.0) ? _pageToUseOnStartup : getPageFromPixels(oldPixels, oldViewportDimensions);
    final double newPixels = getPixelsFromPage(page);

    if (newPixels != oldPixels) {
      correctPixels(newPixels);
      isInitialPixelsValueSet = true;
      return false;
    }
    return result;
  }

  @override
  PageMetrics copyWith({
    double minScrollExtent,
    double maxScrollExtent,
    double pixels,
    double viewportDimension,
    AxisDirection axisDirection,
    double viewportFraction,
  }) {
    return PageMetrics(
      minScrollExtent: minScrollExtent ?? this.minScrollExtent,
      maxScrollExtent: maxScrollExtent ?? this.maxScrollExtent,
      pixels: pixels ?? this.pixels,
      viewportDimension: viewportDimension ?? this.viewportDimension,
      axisDirection: axisDirection ?? this.axisDirection,
      viewportFraction: viewportFraction ?? this.viewportFraction,
    );
  }
}
