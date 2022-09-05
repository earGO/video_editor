import 'dart:ui';

import 'package:video_editor/domain/bloc/controller.dart';

mixin CalculateCovertRectAndLayoutMixin {
  Rect calculateCoverRect({
    required VideoEditorController controller,
    required Size layout,
  }) {
    final Offset min = controller.minCrop;
    final Offset max = controller.maxCrop;
    return Rect.fromPoints(
      Offset(
        min.dx * layout.width,
        min.dy * layout.height,
      ),
      Offset(
        max.dx * layout.width,
        max.dy * layout.height,
      ),
    );
  }

  Size calculateLayout({required double aspect, required double height}) {
    return aspect < 1.0
        ? Size(height * aspect, height)
        : Size(height, height / aspect);
  }
}
