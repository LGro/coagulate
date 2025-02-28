// Copyright 2024 - 2025 The Coagulate Authors. All rights reserved.
// SPDX-License-Identifier: MPL-2.0

import 'dart:typed_data';
import 'dart:math' as math;

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../data/models/coag_contact.dart';
import '../../data/repositories/contacts.dart';
import '../contact_details/page.dart';
import '../profile/page.dart';
import '../utils.dart';
import '../widgets/searchable_list.dart';
import 'cubit.dart';

// class CustomRenderSliverPinnedPersistentHeader
//     extends RenderSliverPinnedPersistentHeader {
//   CustomRenderSliverPinnedPersistentHeader(
//       {super.child,
//       super.showOnScreenConfiguration,
//       super.stretchConfiguration});
//   @override
//   // TODO: implement maxExtent
//   double get maxExtent => 150;

//   @override
//   // TODO: implement minExtent
//   double get minExtent => 100;
// }

class _SliverPersistentHeaderElement extends RenderObjectElement {
  _SliverPersistentHeaderElement(
      _SliverPersistentHeaderRenderObjectWidget super.widget);

  @override
  _RenderSliverPersistentHeaderForWidgetsMixin get renderObject =>
      super.renderObject as _RenderSliverPersistentHeaderForWidgetsMixin;

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    renderObject._element = this;
  }

  @override
  void unmount() {
    renderObject._element = null;
    super.unmount();
  }

  @override
  void update(_SliverPersistentHeaderRenderObjectWidget newWidget) {
    final _SliverPersistentHeaderRenderObjectWidget oldWidget =
        widget as _SliverPersistentHeaderRenderObjectWidget;
    super.update(newWidget);
    final SliverPersistentHeaderDelegate newDelegate = newWidget.delegate;
    final SliverPersistentHeaderDelegate oldDelegate = oldWidget.delegate;
    if (newDelegate != oldDelegate &&
        (newDelegate.runtimeType != oldDelegate.runtimeType ||
            newDelegate.shouldRebuild(oldDelegate))) {
      renderObject.triggerRebuild();
    }
  }

  @override
  void performRebuild() {
    super.performRebuild();
    renderObject.triggerRebuild();
  }

  Element? child;

  void _build(double shrinkOffset, bool overlapsContent) {
    owner!.buildScope(this, () {
      final _SliverPersistentHeaderRenderObjectWidget
          sliverPersistentHeaderRenderObjectWidget =
          widget as _SliverPersistentHeaderRenderObjectWidget;
      child = updateChild(
        child,
        sliverPersistentHeaderRenderObjectWidget.delegate
            .build(this, shrinkOffset, overlapsContent),
        null,
      );
    });
  }

  @override
  void forgetChild(Element child) {
    assert(child == this.child);
    this.child = null;
    super.forgetChild(child);
  }

  @override
  void insertRenderObjectChild(covariant RenderBox child, Object? slot) {
    assert(renderObject.debugValidateChild(child));
    renderObject.child = child;
  }

  @override
  void moveRenderObjectChild(
      covariant RenderObject child, Object? oldSlot, Object? newSlot) {
    assert(false);
  }

  @override
  void removeRenderObjectChild(covariant RenderObject child, Object? slot) {
    renderObject.child = null;
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    if (child != null) {
      visitor(child!);
    }
  }
}

mixin _RenderSliverPersistentHeaderForWidgetsMixin
    on RenderSliverPersistentHeader {
  _SliverPersistentHeaderElement? _element;

  @override
  double get minExtent =>
      (_element!.widget as _SliverPersistentHeaderRenderObjectWidget)
          .delegate
          .minExtent;

  @override
  double get maxExtent =>
      (_element!.widget as _SliverPersistentHeaderRenderObjectWidget)
          .delegate
          .maxExtent;

  @override
  void updateChild(double shrinkOffset, bool overlapsContent) {
    assert(_element != null);
    _element!._build(shrinkOffset, overlapsContent);
  }

  @protected
  void triggerRebuild() {
    markNeedsLayout();
  }
}

abstract class _SliverPersistentHeaderRenderObjectWidget
    extends RenderObjectWidget {
  const _SliverPersistentHeaderRenderObjectWidget({required this.delegate});

  final SliverPersistentHeaderDelegate delegate;

  @override
  _SliverPersistentHeaderElement createElement() =>
      _SliverPersistentHeaderElement(this);

  @override
  _RenderSliverPersistentHeaderForWidgetsMixin createRenderObject(
      BuildContext context);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(
      DiagnosticsProperty<SliverPersistentHeaderDelegate>(
        'delegate',
        delegate,
      ),
    );
  }
}

// Trims the specified edges of the given `Rect` [original], so that they do not
// exceed the given values.
Rect? _trim(
  Rect? original, {
  double top = -double.infinity,
  double right = double.infinity,
  double bottom = double.infinity,
  double left = -double.infinity,
}) =>
    original?.intersect(Rect.fromLTRB(left, top, right, bottom));

/// A sliver with a [RenderBox] child which never scrolls off the viewport in
/// the positive scroll direction, and which first scrolls on at a full size but
/// then shrinks as the viewport continues to scroll.
///
/// This sliver avoids overlapping other earlier slivers where possible.
abstract class CustomRenderSliverPinnedPersistentHeader
    extends RenderSliverPersistentHeader {
  /// Creates a sliver that shrinks when it hits the start of the viewport, then
  /// stays pinned there.
  CustomRenderSliverPinnedPersistentHeader({
    super.child,
    super.stretchConfiguration,
    this.showOnScreenConfiguration =
        const PersistentHeaderShowOnScreenConfiguration(),
  });

  /// Specifies the persistent header's behavior when `showOnScreen` is called.
  ///
  /// If set to null, the persistent header will delegate the `showOnScreen` call
  /// to it's parent [RenderObject].
  PersistentHeaderShowOnScreenConfiguration? showOnScreenConfiguration;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null && geometry!.visible) {
      offset += switch (applyGrowthDirectionToAxisDirection(
          constraints.axisDirection, constraints.growthDirection)) {
        AxisDirection.up => Offset(
            0.0,
            geometry!.paintExtent -
                childMainAxisPosition(child!) -
                childExtent),
        AxisDirection.left => Offset(
            geometry!.paintExtent - childMainAxisPosition(child!) - childExtent,
            0.0),
        AxisDirection.right => Offset(childMainAxisPosition(child!), 0.0),
        AxisDirection.down => Offset(0.0, childMainAxisPosition(child!)),
      };
      context.paintChild(
          child!,
          // NOTE[COAGULATE]: Hacky limit the offset, i.e. pinning to bottom
          Offset(
              0,
              math.min(offset.dy,
                  constraints.viewportMainAxisExtent - childExtent)));
    }
  }

  @override
  void performLayout() {
    final SliverConstraints constraints = this.constraints;
    final double maxExtent = this.maxExtent;
    final bool overlapsContent = constraints.overlap > 0.0;
    layoutChild(constraints.scrollOffset, maxExtent,
        overlapsContent: overlapsContent);
    final double effectiveRemainingPaintExtent =
        math.max(0, constraints.remainingPaintExtent - constraints.overlap);
    final double layoutExtent = clampDouble(
        maxExtent - constraints.scrollOffset,
        0.0,
        effectiveRemainingPaintExtent);
    final double stretchOffset =
        stretchConfiguration != null ? constraints.overlap.abs() : 0.0;
    geometry = SliverGeometry(
      scrollExtent: maxExtent,
      paintOrigin: constraints.overlap,
      paintExtent: math.min(childExtent, effectiveRemainingPaintExtent),
      layoutExtent:
          layoutExtent, //math.min(maxExtent, effectiveRemainingPaintExtent),
      maxPaintExtent: maxExtent + stretchOffset,
      maxScrollObstructionExtent: minExtent,
      cacheExtent: layoutExtent > 0.0
          ? -constraints.cacheOrigin + layoutExtent
          : layoutExtent,
      hasVisualOverflow:
          true, // Conservatively say we do have overflow to avoid complexity.
    );
  }

  @override
  double childMainAxisPosition(RenderBox child) => 0.0;

  @override
  void showOnScreen({
    RenderObject? descendant,
    Rect? rect,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
  }) {
    final Rect? localBounds = descendant != null
        ? MatrixUtils.transformRect(
            descendant.getTransformTo(this), rect ?? descendant.paintBounds)
        : rect;

    final Rect? newRect = switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      AxisDirection.up => _trim(localBounds, bottom: childExtent),
      AxisDirection.left => _trim(localBounds, right: childExtent),
      AxisDirection.right => _trim(localBounds, left: 0),
      AxisDirection.down => _trim(localBounds, top: 0),
    };

    super.showOnScreen(
      descendant: this,
      rect: newRect,
      duration: duration,
      curve: curve,
    );
  }
}

class _RenderSliverPinnedPersistentHeaderForWidgets
    extends CustomRenderSliverPinnedPersistentHeader
    with _RenderSliverPersistentHeaderForWidgetsMixin {
  _RenderSliverPinnedPersistentHeaderForWidgets({
    super.stretchConfiguration,
    super.showOnScreenConfiguration,
  });
}

class _SliverPinnedPersistentHeader
    extends _SliverPersistentHeaderRenderObjectWidget {
  const _SliverPinnedPersistentHeader({
    required super.delegate,
  });

  @override
  _RenderSliverPersistentHeaderForWidgetsMixin createRenderObject(
          BuildContext context) =>
      _RenderSliverPinnedPersistentHeaderForWidgets(
        stretchConfiguration: delegate.stretchConfiguration,
        showOnScreenConfiguration: delegate.showOnScreenConfiguration,
      );

  @override
  void updateRenderObject(BuildContext context,
      covariant _RenderSliverPinnedPersistentHeaderForWidgets renderObject) {
    renderObject
      ..stretchConfiguration = delegate.stretchConfiguration
      ..showOnScreenConfiguration = delegate.showOnScreenConfiguration;
  }
}

// TOP Element

class CustomRenderSliverToBoxAdapter extends RenderSliverSingleBoxAdapter {
  /// Creates a [RenderSliver] that wraps a [RenderBox].
  CustomRenderSliverToBoxAdapter({
    super.child,
  });

  @override
  Size getAbsoluteSizeRelativeToOrigin() {
    // TODO: implement getAbsoluteSizeRelativeToOrigin
    return super.getAbsoluteSizeRelativeToOrigin();
  }

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final SliverConstraints constraints = this.constraints;
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final double childExtent = switch (constraints.axis) {
      Axis.horizontal => child!.size.width,
      Axis.vertical => child!.size.height,
    };
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );
    setChildParentData(child!, constraints, geometry!);
  }
}

class CustomRenderSliverSingleBoxAdapter extends RenderSliverSingleBoxAdapter {
  CustomRenderSliverSingleBoxAdapter();
  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    final SliverConstraints constraints = this.constraints;
    child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    final double childExtent = switch (constraints.axis) {
      Axis.horizontal => child!.size.width,
      Axis.vertical => child!.size.height,
    };
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
        scrollExtent: 200,
        paintExtent: paintedChildSize,
        maxPaintExtent: childExtent,
        hasVisualOverflow: true);
    setChildParentData(child!, constraints, geometry!);
  }
}

class CustomSliverSingleBoxAdapter extends SingleChildRenderObjectWidget {
  const CustomSliverSingleBoxAdapter({super.key, super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      CustomRenderSliverSingleBoxAdapter();
}

class ScrollableSections extends StatelessWidget {
  const ScrollableSections({super.key});

  @override
  Widget build(BuildContext context) => CustomScrollView(
        slivers: [
          CustomSliverSingleBoxAdapter(
              child: Container(
            color: Colors.red,
            height: 1000,
            child: Center(child: Text('Top Section')),
          )),
          // SliverPersistentHeader(
          //   delegate: FixedSizeSliverHeader(
          //     maxHeight: 600, // Maximum size limit
          //   ),
          //   pinned: false, // Stays visible
          // ),
          // SliverList(
          //   delegate: SliverChildListDelegate([
          //     Container(
          //       color: Colors.red,
          //       height: 1000,
          //       child: Center(child: Text('Top Section')),
          //     ),
          //   ]),
          // ),
          _SliverPinnedPersistentHeader(
            delegate: CustomSliverPersistentHeaderDelegate(
              child: Container(
                color: Colors.green,
                child: Center(child: Text('Middle Section')),
              ),
              maxHeight: 50,
              minHeight: 50,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
                color: Colors.blue,
                height: 100,
                child: Center(child: Text('Bottom Section Item $index')),
              ),
              childCount: 20,
            ),
          ),
        ],
      );
}

class FixedSizeSliverHeader extends SliverPersistentHeaderDelegate {
  final double maxHeight;

  FixedSizeSliverHeader({required this.maxHeight});

  @override
  double get minExtent => maxHeight; // Keep it fixed
  @override
  double get maxExtent => maxHeight; // No growth beyond maxHeight

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      CustomScrollView(slivers: [
        SliverList.list(children: [
          Container(
            color: Colors.red,
            alignment: Alignment.center,
            height: 1500,
            child: Text(
              'Fixed Size Sliver',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ])
      ]);

  @override
  bool shouldRebuild(FixedSizeSliverHeader oldDelegate) => false;
}

class CustomSliverPersistentHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double maxHeight;
  final double minHeight;

  CustomSliverPersistentHeaderDelegate({
    required this.child,
    required this.maxHeight,
    required this.minHeight,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
