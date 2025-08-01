class GridResponsiveHelper {
  static int calculateCrossAxisCount({
    required double screenWidth,
    required int defaultCount,
  }) {
    if (defaultCount == 3) {
      return switch (screenWidth) {
        > 1200 => 6,
        > 900 => 5,
        > 600 => 4,
        _ => 3,
      };
    }

    if (defaultCount == 2) {
      return switch (screenWidth) {
        > 1200 => 4,
        > 900 => 3,
        > 600 => 2,
        _ => 2,
      };
    }

    return defaultCount;
  }
  static double calculateAspectRatio(double screenWidth) {
    return screenWidth < 400 ? 0.5 : 0.6;
  }
}