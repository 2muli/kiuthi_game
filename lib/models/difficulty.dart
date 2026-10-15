enum Difficulty {
  easy,
  intermediate,
  expert;

  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.expert:
        return 'Expert';
    }
  }

  String get description {
    switch (this) {
      case Difficulty.easy:
        return 'A friendly challenge for learning Kiuthi.';
      case Difficulty.intermediate:
        return 'Plan ahead and defend against stronger moves.';
      case Difficulty.expert:
        return 'Face a computer that searches deeper and evaluates positions carefully.';
    }
  }

  static Difficulty parse(String? value) {
    for (final difficulty in Difficulty.values) {
      if (difficulty.name == value) return difficulty;
    }
    return Difficulty.easy;
  }
}
