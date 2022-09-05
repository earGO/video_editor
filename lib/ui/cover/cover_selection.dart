import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_editor/domain/bloc/controller.dart';
import 'package:video_editor/domain/entities/cover_data.dart';
import 'package:video_editor/domain/entities/transform_data.dart';
import 'package:video_editor/ui/cover/methods/buildSingleCover.dart';
import 'package:video_editor/ui/cover/methods/calculateCovertRect.dart';
import 'package:video_editor/ui/cover/methods/generateThumbnails.dart';

class CoverSelection extends StatefulWidget {
  /// Slider that allow to select a generated cover
  const CoverSelection({
    Key? key,
    required this.controller,
    this.height = 60,
    this.quality = 10,
    this.quantity = 5,
  }) : super(key: key);

  /// The [controller] param is mandatory so every change in the controller settings will propagate in the cover selection view
  final VideoEditorController controller;

  /// The [height] param specifies the height of the generated thumbnails
  final double height;

  /// The [quality] param specifies the quality of the generated thumbnails, from 0 to 100 ([more info](https://pub.dev/packages/video_thumbnail))
  final int quality;

  /// The [quantity] param specifies the quantity of thumbnails to generate
  final int quantity;

  @override
  State<CoverSelection> createState() => _CoverSelectionState();
}

class _CoverSelectionState extends State<CoverSelection>
    with
        AutomaticKeepAliveClientMixin,
        GenerateThumbnailsMethodMixin,
        BuildSingleCoverMethodMixin,
        CalculateCovertRectAndLayoutMixin {
  double _aspect = 1.0, _width = 1.0;
  Duration? _startTrim, _endTrim;
  Size _layout = Size.zero;
  final ValueNotifier<Rect> _rect = ValueNotifier<Rect>(Rect.zero);
  final ValueNotifier<TransformData> _transform =
      ValueNotifier<TransformData>(TransformData());

  late Stream<List<CoverData>> _stream = (() => generateThumbnails(
      controller: widget.controller,
      thumbnailImageQuality: widget.quality,
      thumbnailsQuantity: widget.quantity))();

  @override
  void dispose() {
    widget.controller.removeListener(_scaleRect);
    _transform.dispose();
    _rect.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _aspect = widget.controller.preferredCropAspectRatio ??
        widget.controller.video.value.aspectRatio;
    _startTrim = widget.controller.startTrim;
    _endTrim = widget.controller.endTrim;
    widget.controller.addListener(_scaleRect);

    // init the widget with controller values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scaleRect();
    });
  }

  @override
  bool get wantKeepAlive => true;

  void _scaleRect() {
    _rect.value =
        calculateCoverRect(controller: widget.controller, layout: _layout);
    _transform.value = TransformData.fromRect(
      _rect.value,
      _layout,
      widget.controller,
    );

    if (widget.controller.preferredCropAspectRatio != null &&
        _aspect != widget.controller.preferredCropAspectRatio) {
      _aspect = widget.controller.preferredCropAspectRatio!;
      _layout = calculateLayout(aspect: _aspect, height: widget.height);
    }

    // if trim values changed generate new thumbnails
    if (!widget.controller.isTrimming &&
        (_startTrim != widget.controller.startTrim ||
            _endTrim != widget.controller.endTrim)) {
      _startTrim = widget.controller.startTrim;
      _endTrim = widget.controller.endTrim;
      setState(() {
        _stream = generateThumbnails(
            controller: widget.controller,
            thumbnailImageQuality: widget.quality,
            thumbnailsQuantity: widget.quantity);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(builder: (_, box) {
      final double width = box.maxWidth;
      if (_width != width) {
        _width = width;
        _layout = calculateLayout(aspect: _aspect, height: widget.height);
        _rect.value =
            calculateCoverRect(controller: widget.controller, layout: _layout);
      }

      return StreamBuilder(
          stream: _stream,
          builder: (_, AsyncSnapshot<List<CoverData>> snapshot) {
            final data = snapshot.data;
            return snapshot.hasData
                ? Wrap(
                    runSpacing: 10.0,
                    spacing: 10.0,
                    children: data!
                        .map((coverData) => ValueListenableBuilder(
                            valueListenable: _transform,
                            builder: (_, TransformData transform, __) {
                              return ValueListenableBuilder(
                                valueListenable:
                                    widget.controller.selectedCoverNotifier,
                                builder: (context, CoverData? selectedCover,
                                        __) =>
                                    buildSingleCover(coverData, transform,
                                        widget.controller.coverStyle,
                                        isSelected: coverData.sameTime(widget
                                            .controller.selectedCoverVal!),
                                        controller: widget.controller,
                                        layout: _layout,
                                        rect: _rect),
                              );
                            }))
                        .toList()
                        .cast<Widget>(),
                  )
                : const SizedBox();
          });
    });
  }
}
