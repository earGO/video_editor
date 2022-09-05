import 'package:flutter/material.dart';
import 'package:video_editor/domain/bloc/controller.dart';
import 'package:video_editor/domain/entities/cover_data.dart';
import 'package:video_editor/domain/entities/cover_style.dart';
import 'package:video_editor/domain/entities/transform_data.dart';
import 'package:video_editor/ui/crop/crop_grid_painter.dart';
import 'package:video_editor/ui/transform.dart';

mixin BuildSingleCoverMethodMixin {
  Widget buildSingleCover(
      CoverData cover, TransformData transform, CoverSelectionStyle coverStyle,
      {required bool isSelected,
      required VideoEditorController controller,
      required Size layout,
      required ValueNotifier<Rect> rect}) {
    return InkWell(
      onTap: () => controller.updateSelectedCover(cover),
      child: Stack(
        alignment: coverStyle.selectedIndicatorAlign,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? coverStyle.selectedBorderColor
                    : Colors.transparent,
                width: coverStyle.selectedBorderWidth,
              ),
            ),
            child: CropTransform(
              transform: transform,
              child: Container(
                alignment: Alignment.center,
                height: layout.height,
                width: layout.width,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image(
                      image: MemoryImage(cover.thumbData!),
                      width: layout.width,
                      height: layout.height,
                    ),
                    CustomPaint(
                      size: layout,
                      painter: CropGridPainter(
                        rect.value,
                        showGrid: false,
                        style: controller.cropStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          isSelected && coverStyle.selectedIndicator != null
              ? coverStyle.selectedIndicator!
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
