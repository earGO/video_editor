import 'package:flutter/foundation.dart';
import 'package:video_editor/domain/bloc/controller.dart';
import 'package:video_editor/domain/entities/cover_data.dart';

mixin GenerateThumbnailsMethodMixin {
  Stream<List<CoverData>> generateThumbnails(
      {required VideoEditorController controller,
      required int thumbnailsQuantity,
      required int thumbnailImageQuality}) async* {
    final int duration = controller.isTrimmmed
        ? (controller.endTrim - controller.startTrim).inMilliseconds
        : controller.videoDuration.inMilliseconds;
    final double eachPart = duration / thumbnailsQuantity;
    List<CoverData> byteList = [];
    for (int i = 0; i < thumbnailsQuantity; i++) {
      try {
        final CoverData bytes = await controller.generateCoverThumbnail(
            timeMs: (controller.isTrimmmed
                    ? (eachPart * i) + controller.startTrim.inMilliseconds
                    : (eachPart * i))
                .toInt(),
            quality: thumbnailImageQuality);

        if (bytes.thumbData != null) {
          byteList.add(bytes);
        }
      } catch (e) {
        debugPrint(e.toString());
      }

      yield byteList;
    }
  }
}
